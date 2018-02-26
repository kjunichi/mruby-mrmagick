#include <Magick++.h>
#include <iostream>
#include <string.h>

#include "mruby.h"
#include "mruby/array.h"
#include "mruby/data.h"
#include "mruby/hash.h"
#include "mruby/string.h"
#include "mruby/variable.h"

#include "dummy_exif.h"

using namespace std;
using namespace Magick;

static bool gMagickInitFlg = false;

void
myInitializeMagick()
{
  if (!gMagickInitFlg) {
    InitializeMagick(".");
    gMagickInitFlg = true;
  }
}

static void
getSrcImageFilePath(mrb_state *mrb, mrb_value obj, string *path)
{
  mrb_value val = mrb_iv_get(mrb, obj, mrb_intern_lit(mrb, "@parentPath"));
  string filepath(RSTRING_PTR(val), RSTRING_LEN(val));
  *path = filepath;
}

extern "C" void
scale(const char *srcPath, const char *destPath, const char *ratio)
{
  myInitializeMagick();
  Image image;
  image.read(srcPath);
  // calc geom.
  image.scale(ratio);
  image.write(destPath);
}

extern "C" void
blur(const char *srcPath, const char *destPath, const double radius, const double sigma)
{
  myInitializeMagick();
  Image image;
  image.read(srcPath);
  // calc geom.
  image.blur(radius, sigma);
  image.write(destPath);
}
extern "C" mrb_value
mrb_mrmagick_get_exif_by_entry(mrb_state *mrb, mrb_value self)
{
  string srcImageFilePath;

  mrb_value obj, val;

  mrb_get_args(mrb, "o", &obj);

  val = mrb_iv_get(mrb, obj, mrb_intern_lit(mrb, "@exifKey"));
  string tmpstr(RSTRING_PTR(val), RSTRING_LEN(val));
  string exiftag = "EXIF:" + tmpstr;
  getSrcImageFilePath(mrb, obj, &srcImageFilePath);
  Image img;
  img.read(srcImageFilePath.c_str());
  string exifStr = img.attribute(exiftag);

  const char *cstr = exifStr.c_str();

  return mrb_str_new_cstr(mrb, cstr);
}

static void
writeAndBlob(Image *img, mrb_state *mrb, mrb_value obj)
{
  string srcImageFilePath;
  mrb_value isBlob = mrb_iv_get(mrb, obj, mrb_intern_lit(mrb, "@isBlob"));

  if(mrb_bool(isBlob)) {
    // read image from blob
    mrb_value mrbBlob = mrb_iv_get(mrb, obj, mrb_intern_lit(mrb, "@blob"));

    Blob blob(RSTRING_PTR(mrbBlob), RSTRING_LEN(mrbBlob));
    img->read(blob);
  } else {
    // read image from file.
    getSrcImageFilePath(mrb, obj, &srcImageFilePath);

    img->read(srcImageFilePath.c_str());
  }
  mrb_value ov = mrb_iv_get(mrb, obj, mrb_intern_lit(mrb, "@orientationv"));
  if (mrb_fixnum_p(ov)) {
    Blob blob = img->profile("exif");
    if (blob.data() == NULL) {
      // we generate dummy exif data.
      Blob exifdata(dexifData, dexifDataLength);
      img->profile("exif", exifdata);
      // make own exif data.
    }

    int orientation = mrb_fixnum(ov);
    switch (orientation) {
    case 1:
      img->orientation(TopLeftOrientation);
      img->attribute("EXIF:Orientation", "1");
      break;
    case 2:
      img->orientation(TopRightOrientation);
      img->attribute("EXIF:Orientation", "2");
      break;
    case 3:
      img->orientation(BottomRightOrientation);
      img->attribute("EXIF:Orientation", "3");
      break;
    case 4:
      img->orientation(BottomLeftOrientation);
      img->attribute("EXIF:Orientation", "4");
      break;
    case 5:
      img->orientation(LeftTopOrientation);
      img->attribute("EXIF:Orientation", "5");
      break;
    case 6:
      img->orientation(RightTopOrientation);
      img->attribute("EXIF:Orientation", "6");
      break;
    case 7:
      img->orientation(RightBottomOrientation);
      img->attribute("EXIF:Orientation", "7");
      break;
    case 8:
      img->orientation(LeftBottomOrientation);
      img->attribute("EXIF:Orientation", "8");
      break;
    default:
      break;
    }
  }
  // exif処理
  // ハッシュに登録されている項目を書き込む
  mrb_value exifObj = mrb_iv_get(mrb, obj, mrb_intern_lit(mrb, "@exif"));
  if (mrb_hash_p(exifObj)) {
    mrb_value keys = mrb_hash_keys(mrb, exifObj);
    int len = RARRAY_LEN(keys);

    for (int i = 0; i < len; i++) {
      mrb_value key = mrb_ary_ref(mrb, keys, i);
      mrb_value ev = mrb_hash_get(mrb, exifObj, key);
      string exifValue(RSTRING_PTR(ev), RSTRING_LEN(ev));
      string exiftag = "EXIF:";
      exiftag.append(RSTRING_PTR(key), RSTRING_LEN(key));

      img->attribute(exiftag, exifValue);
    }
  }
  /*
   # これまでのコマンドを実行する。
   */
  mrb_value val = mrb_iv_get(mrb, obj, mrb_intern_lit(mrb, "@cmd"));
  if (mrb_nil_p(val)) {
    return;
  }
  int idx = 0;

  // for c in @cmd do
  int num_cmds = RARRAY_LEN(val);
  for (int i = 0; i < num_cmds; ++i) {
    mrb_value c = mrb_ary_ref(mrb, val, i);
    mrb_value params = mrb_funcall(mrb, c, "split", 1, mrb_str_new_cstr(mrb, " "));
    mrb_value v = mrb_funcall(mrb, c, "include?", 1, mrb_str_new_cstr(mrb, "-resize"));
    if (mrb_bool(v)) {
      // Mrmagick::Capi.scale(params[1], params[4], params[3])
      v = mrb_ary_ref(mrb, params, 3);
      string scalestr(RSTRING_PTR(v), RSTRING_LEN(v));
      img->scale(scalestr.c_str());
    }
    v = mrb_funcall(mrb, c, "include?", 1, mrb_str_new_cstr(mrb, "-blur"));
    if (mrb_bool(v)) {
      // radius_sigma=params[3].split(",")
      mrb_value params_3 = mrb_ary_ref(mrb, params, 3);
      mrb_value radius_sigma = mrb_funcall(mrb, params_3, "split", 1, mrb_str_new_cstr(mrb, ","));
      v = mrb_funcall(mrb, radius_sigma, "length", 0);
      float sigma = 0.5;
      if (mrb_fixnum(v) >= 2) {
        mrb_value radius_sigma_1 = mrb_ary_ref(mrb, radius_sigma, 1);
        v = mrb_funcall(mrb, radius_sigma_1, "to_f", 0);
        sigma = mrb_float(v);
      }
      v = mrb_funcall(mrb, mrb_ary_ref(mrb, radius_sigma, 0), "to_f", 0);
      float radius = mrb_float(v);
      img->blur(radius, sigma);
    }
    v = mrb_funcall(mrb, c, "include?", 1, mrb_str_new_cstr(mrb, "-rotate"));
    if (mrb_bool(v)) {
      v = mrb_ary_ref(mrb, params, 3);
      v = mrb_funcall(mrb, v, "to_f", 0);
      float rot = mrb_float(v);
      img->rotate((double)rot);
      img->page("0x0+0+0");
    }
    v = mrb_funcall(mrb, c, "include?", 1, mrb_str_new_cstr(mrb, "-flop"));
    if (mrb_bool(v)) {
      img->flop();
    }
    v = mrb_funcall(mrb, c, "include?", 1, mrb_str_new_cstr(mrb, "-flip"));
    if (mrb_bool(v)) {
      img->flip();
    }
    v = mrb_funcall(mrb, c, "include?", 1, mrb_str_new_cstr(mrb, "-crop"));
    if (mrb_bool(v)) {
      v = mrb_ary_ref(mrb, params, 3);
      Geometry geom(string(RSTRING_PTR(v), RSTRING_LEN(v)));
      geom.aspect(false);
      img->crop(geom);
      img->page("0x0+0+0");
    }
    ++idx;
  }
}

extern "C" mrb_value
mrb_mrmagick_write(mrb_state *mrb, mrb_value self)
{
  Image img;

  mrb_value obj;

  mrb_get_args(mrb, "o", &obj);

  mrb_value val = mrb_iv_get(mrb, obj, mrb_intern_lit(mrb, "@outpath"));
  string distImageFilePath(RSTRING_PTR(val), RSTRING_LEN(val));

  writeAndBlob(&img, mrb, obj);

  img.write(distImageFilePath.c_str());
  return mrb_nil_value();
}

/**
ファイルパスとBlobの配列を受け取り、gif animationとして書き出す
*/
extern "C" mrb_value
mrb_mrmagick_write_gif(mrb_state *mrb, mrb_value self)
{
  mrb_value obj;
  char *path = NULL;

  // get gif file name to write.
  mrb_get_args(mrb, "zo", &path, &obj);
  if (mrb_array_p(obj)) {
    list<Image> ilist;

    int len = RARRAY_LEN(obj);
    for (int i = 0; i < len; i++) {
      Blob blob(RSTRING_PTR(mrb_ary_ref(mrb, obj, i)), RSTRING_LEN(mrb_ary_ref(mrb, obj, i)));
      Image img(blob);
      img.animationDelay(10);
      img.animationIterations(0);
      ilist.push_back(img);
    }
    Image appended;
    writeImages(ilist.begin(), ilist.end(), path);
  }
  return mrb_nil_value();
}

extern "C" mrb_value
mrb_mrmagick_to_blob(mrb_state *mrb, mrb_value self)
{
  mrb_value obj;

  mrb_get_args(mrb, "o", &obj);

  Image img;
  writeAndBlob(&img, mrb, obj);

  Blob blob;
  img.write(&blob);

  mrb_value val;
  val = mrb_str_new(mrb, (const char *)blob.data(), blob.length());
  return val;
}

/*
 * Return width of the image.
 */
extern "C" mrb_value
mrb_mrmagick_get_columns(mrb_state *mrb, mrb_value self)
{
  mrb_value obj;
  mrb_get_args(mrb, "o", &obj);

  Image img;
  writeAndBlob(&img, mrb, obj);
  Blob blob;
  img.write(&blob);
  return mrb_fixnum_value((int)img.columns());
}

/*
 * Return height of the image.
 *
 * @param [Image] image.
 */
extern "C" mrb_value
mrb_mrmagick_get_rows(mrb_state *mrb, mrb_value self)
{
  mrb_value obj;
  mrb_get_args(mrb, "o", &obj);

  Image img;
  writeAndBlob(&img, mrb, obj);
  Blob blob;
  img.write(&blob);
  return mrb_fixnum_value((int)img.rows());
}

/*
 * Return format of the image.
 *
 * @param [Image] image.
 */
extern "C" mrb_value
mrb_mrmagick_get_format(mrb_state *mrb, mrb_value self)
{
  mrb_value obj;
  mrb_get_args(mrb, "o", &obj);

  Image img;
  writeAndBlob(&img, mrb, obj);
  Blob blob;
  img.write(&blob);
  string format = img.format();
  return mrb_str_new(mrb, format.c_str(), format.length());
}

/*
 * Return imagemagick's support format list.
 *
 */
extern "C" mrb_value
mrb_mrmagick_formats(mrb_state *mrb, mrb_value self)
{
  string str;
  mrb_value table = mrb_hash_new(mrb);

  list<CoderInfo> coderList;
   coderInfoList( &coderList,           // Reference to output list 
                 CoderInfo::TrueMatch, // Match readable formats 
                 CoderInfo::AnyMatch,  // Don't care about writable formats 
                 CoderInfo::AnyMatch); // Don't care about multi-frame support 
  list<CoderInfo>::iterator entry = coderList.begin(); 
  while(entry != coderList.end()) 
  {
    // B 	is "*" if the format has native blob support, and "-" otherwise.
    // R 	is "r" if ImageMagick can read the format, and "-" otherwise.
    // W 	is "w" if ImageMagick can write the format, and "-" otherwise.
    // A 	is "+" if the format supports multi-image files, and "-" otherwise.
    
    
    string keystr = entry->name();
    mrb_value key = mrb_str_new(mrb, keystr.c_str(), keystr.length());

    //str += "=>";

    //str += entry->description();
    //str += "Readable = "; 
    str = "*";
    if ( entry->isReadable() ) 
      str += "r"; 
    else 
      str += "-"; 
    //str += "Writable = "; 
    if ( entry->isWritable() ) 
      str += "w"; 
    else 
      str += "-"; 
    //str +=  ", "; 
    //str += "Multiframe = "; 
    if ( entry->isMultiFrame() ) 
      str += "+"; 
    else 
      str += "-"; 
    //str += "\n";

    entry ++;
    mrb_value val = mrb_str_new(mrb, str.c_str(), str.length());
    mrb_hash_set(mrb, table, key, val);
  }
  //mrb_iv_set(mrb, self, mrb_intern_lit(mrb, "table"), table);
  return table;
}
