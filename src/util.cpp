#include <Magick++.h>
#include <iostream>
#include <string.h>

#include "mruby.h"
#include "mruby/data.h"
#include "mruby/string.h"
#include "mruby/array.h"
#include "mruby/variable.h"

using namespace std;
using namespace Magick;

static bool gMagickInitFlg=false;

void myInitializeMagick() {
	if(!gMagickInitFlg) {
		InitializeMagick("./mruby");
		gMagickInitFlg=true;
	}
}

extern "C" void myputs() {
	cout <<"Hello, mruby!"<<endl;
}

extern "C" void scale(const char *srcPath,const char *destPath, const char *ratio) {
	myInitializeMagick();
	Image image;
	image.read(srcPath);
	// calc geom.
	image.scale(ratio);
	image.write(destPath);
}

extern "C" void blur(const char *srcPath,const char *destPath,
	const double radius, const double sigma) {
	myInitializeMagick();
	Image image;
	image.read(srcPath);
	// calc geom.
	cout<<radius<<","<<sigma<<endl;
	image.blur(radius, sigma);
	image.write(destPath);
}

extern "C" mrb_value mrb_mrmagick_write(mrb_state *mrb, mrb_value self)
{
	char srcImageFilePath[512],distImageFilePath[512],buf[256];

  mrb_value obj,val;
  mrb_get_args(mrb, "o", &obj);
  mrb_funcall(mrb,mrb_top_self(mrb), "p", 1, obj);
	val = mrb_iv_get(mrb, obj, mrb_intern_lit(mrb, "@parentPath"));
	strncpy(srcImageFilePath, RSTRING_PTR( val ), RSTRING_LEN( val ));
	srcImageFilePath[RSTRING_LEN( val )]='\0';

	cout << "srcImageFilePath=["<<srcImageFilePath<<"]"<<endl;

	val = mrb_iv_get(mrb, obj, mrb_intern_lit(mrb, "@outpath"));
	strncpy(distImageFilePath, RSTRING_PTR( val ), RSTRING_LEN( val ));
	distImageFilePath[RSTRING_LEN( val )]='\0';
	cout << "distImageFilePath=["<<distImageFilePath<<"]"<<endl;

	// 画像ファイルを読み込む
	Image img;
	img.read(srcImageFilePath);
	/*
	# これまでのコマンドを実行する。
	*/
	// lastIdx = @cmd.size-1
	val = mrb_iv_get(mrb, obj, mrb_intern_lit(mrb, "@cmd"));

	int lastIdx = RARRAY_LEN(val) - 1;
	cout << "lastIdx = " << lastIdx << endl;
	int idx=0;

	//for c in @cmd do
	int num_cmds = RARRAY_LEN(val);
	for(int i = 0; i < num_cmds; ++i) {
  	mrb_value c = mrb_ary_ref(mrb, val, i);
		mrb_funcall(mrb,mrb_top_self(mrb), "p", 1, c);
		//params = c.split(" ")
		mrb_value params = mrb_funcall(mrb,c, "split", 1, mrb_str_new_cstr(mrb, " "));
		mrb_funcall(mrb,mrb_top_self(mrb), "p", 1, params);

		// if c.include?("-resize") then
		mrb_value v = mrb_funcall(mrb,c, "include?", 1, mrb_str_new_cstr(mrb, "-resize"));
		if(mrb_bool(v)) {
			// Mrmagick::Capi.scale(params[1], params[4], params[3])
			v = mrb_ary_ref( mrb, params, 3);
			strncpy(buf,RSTRING_PTR(v),RSTRING_LEN(v));
			buf[RSTRING_LEN(v)]='\0';
			img.scale(buf);
		} else {
			//elsif c.include?("-blur") then
			mrb_value v = mrb_funcall(mrb,c, "include?", 1, mrb_str_new_cstr(mrb, "-blur"));
			if(mrb_bool(v)) {
				// radius_sigma=params[3].split(",")
				mrb_value params_3 = mrb_ary_ref( mrb, params, 3);
				mrb_value radius_sigma = mrb_funcall(mrb,params_3, "split", 1, mrb_str_new_cstr(mrb, ","));
				// if radius_sigma.length<2 then
				//   sigma = 0.5
			 	// else
				//   sigma = radius_sigma[1].to_f;
			 	// end
				v = mrb_funcall(mrb,radius_sigma, "length", 0);
				float sigma = 0.5;
				if(mrb_fixnum(v)>=2) {
						mrb_value radius_sigma_1 = mrb_ary_ref( mrb, radius_sigma, 1);
						v = mrb_funcall(mrb, radius_sigma_1, "to_f",0);
						sigma = mrb_float(v);
				}
				v = mrb_funcall(mrb, mrb_ary_ref(mrb, radius_sigma, 0),"to_f", 0);
				float radius = mrb_float(v);
				cout<<"radius[0],radius[1] = "<<radius<<", "<<sigma<<endl;
				// Mrmagick::Capi.blur(params[1], params[4], radius_sigma[0].to_f, sigma)
				img.blur(radius, sigma);
			}
		}
		++idx;
	}
	img.write(distImageFilePath);
		/*
		else
				rtn = `#{c}`
		end
		idx = idx + 1
	end
	*/
	return mrb_nil_value();
}

extern "C" void image_write(mrb_state *mrb, mrb_value val) {

}
