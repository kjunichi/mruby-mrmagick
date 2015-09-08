# mruby-mrmagick   [![Build Status](https://travis-ci.org/kjunichi/mruby-mrmagick.png?branch=master)](https://travis-ci.org/kjunichi/mruby-mrmagick)
Mrmagick class
## install by mrbgems
- add conf.gem line to `build_config.rb`

```ruby
MRuby::Build.new do |conf|

    # ... (snip) ...

    conf.gem :github => 'kjunichi/mruby-mrmagick'
end
```
## example
```ruby
img = Mrmagick::ImageList.new("sample.png") # read image file.
new_img = img.blur_image(0.0, 8.0) # returns new image which bluerd.
new_img.write("blur.jpg")
```

```ruby
img = Mrmagick::ImageList.new("sample.jpg") # read image file.
new_img = img.scale(0.5) # returns new image which scaled.
new_img.write("half.png")
```

```ruby
img = Mrmagick::ImageList.new("sample.png") # read image file.
img2 = img.blur_image(0.0, 8.0) # returns new image which bluerd.
img3 = img2.scale(4) # returns new image which scaled.
img3.write("blur_x4.jpg")
```

```ruby
img = Mrmagick::ImageList.new("sample.jpg") # read image file.
img.get_exif_by_entry('GPSLatitude')

```

```ruby
img = Mrmagick::ImageList.new("sample.jpg") # read image file.
img2 = img.blur_image(0.0, 8.0) # returns new image which bluerd.
File.open("blob.jpg", "wb") {|f|
  f.print img2.to_blob
}
```

## See also

- [Rubyist Magazine - RedDotRubyConf 2015 レポート](http://magazine.rubyist.net/?0051-RedDotRubyConf2015#l7)
- [ngx_mrubyを使った簡単な画像変換サーバを数分で実装してみた - 人間とウェブの未来](http://hb.matsumoto-r.jp/entry/2015/05/13/234326)

## License
under the MIT License:
- see LICENSE file
