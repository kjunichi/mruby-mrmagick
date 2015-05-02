MRuby::Gem::Specification.new('mruby-mrmagick') do |spec|
  spec.license = 'MIT'
  spec.authors = 'Junichi Kajiwara'

  magick_cflg =  `Magick++-config --cxxflags --cppflags`.chomp!
  magick_cflg.gsub!(/\n/," ")
  #puts magick_cflg
  spec.cxx.flags << magick_cflg
  #ossp_uuid_cflg = `uuid-config --cflags`.chomp!
  #spec.cc.flags << ossp_uuid_cflg
  magick_libs = `Magick++-config --ldflags --libs`.chomp!
  magick_libs.gsub!(/\n/," ")
  spec.linker.flags_before_libraries << magick_libs
  #ossp_uuid_libs = `uuid-config --ldflags --libs`.chomp!
  #spec.linker.flags_before_libraries << ossp_uuid_libs
end
