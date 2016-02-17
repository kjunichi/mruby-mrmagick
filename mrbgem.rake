MRuby::Gem::Specification.new('mruby-mrmagick') do |spec|
  spec.license = 'MIT'
  spec.authors = 'Junichi Kajiwara'

  if build.kind_of?(MRuby::CrossBuild)
    ENV['PKG_CONFIG_PATH'] = "/usr/#{build.host_target}/lib/pkgconfig"
    spec.cxx.flags << "-I/usr/#{build.host_target}/include"
    magick_cflg =  `/usr/#{build.host_target}/bin/Magick++-config --cxxflags --cppflags`.chomp!
    magick_libs = `/usr/#{build.host_target}/bin/Magick++-config --ldflags --libs`.chomp!
  else
    magick_cflg =  `Magick++-config --cxxflags --cppflags`.chomp!
    magick_libs = `Magick++-config --ldflags --libs`.chomp!
  end

  magick_cflg.gsub!(/\n/," ")
  spec.cxx.flags << magick_cflg
  magick_libs.gsub!(/\n/," ")
  spec.linker.flags_before_libraries << magick_libs

  if build.kind_of?(MRuby::CrossBuild)
    spec.linker.flags_before_libraries << "-ljpeg -lpng -lz"
    if %w(i686-pc-linux-gnu x86_64-pc-linux-gnu).include?(build.host_target)
      spec.linker.flags_before_libraries << "-lgomp -lpthread"
    end
    if %w(i386-apple-darwin14 x86_64-apple-darwin14).include?(build.host_target)
      spec.linker.flags_before_libraries << "-lbz2"
    end
    if %w(i686-w64-mingw32 x86_64-w64-mingw32).include?(build.host_target)
      spec.linker.flags_before_libraries << "-Wl,-dn,-lgdi32 -Wl,-dn,-lgomp"
    end
  end

  spec.add_test_dependency 'mruby-io'
  spec.add_dependency 'mruby-array-ext'
  spec.add_dependency 'mruby-print'
end
