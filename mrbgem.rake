MRuby::Gem::Specification.new('mruby-mrmagick') do |spec|
  spec.license = 'MIT'
  spec.authors = 'Junichi Kajiwara'

  if build.kind_of?(MRuby::CrossBuild)
    ENV['PKG_CONFIG_PATH'] = "/usr/#{build.host_target}/lib/pkgconfig"
    spec.cxx.flags << "-I/usr/#{build.host_target}/include"
    magick_cflg =  `/usr/#{build.host_target}/bin/Magick++-config --cxxflags --cppflags`.chomp!
    magick_libs = `/usr/#{build.host_target}/bin/Magick++-config --ldflags --libs`.chomp!
  else
    if ENV['OS'] == 'Windows_NT'
      imPaths = Dir.glob("c:/Program Files/ImageMagick-**").sort!

      imHomeD = imPaths[imPaths.size-1].gsub!('/','\\')
      imHome = imPaths[imPaths.size-1]
      spec.cc.flags << "/I \"#{imHomeD}\\include\""
      spec.cxx.flags << "/I \"#{imHomeD}\\include\""
      spec.linker.library_paths += ["#{imHome}/lib"]
      if imHome.include?("-6") then
        spec.linker.libraries += ['CORE_RL_magick_','CORE_RL_Magick++_','CORE_RL_wand_']
      else
        spec.linker.libraries += ['CORE_RL_MagickCore_','CORE_RL_Magick++_','CORE_RL_MagickWand_']
      end
    else
      magick_cflg =  `Magick++-config --cxxflags --cppflags`.chomp!
      magick_libs = `Magick++-config --ldflags --libs`.chomp!

      magick_cflg.gsub!(/\n/," ")
      spec.cxx.flags << magick_cflg
      magick_libs.gsub!(/\n/," ")
      spec.linker.flags_before_libraries << magick_libs
    end
  end

  

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

MRuby.each_target do
  next if kind_of? MRuby::CrossBuild
  if ENV['OS'] == 'Windows_NT'
    require 'fileutils'
    imPaths = Dir.glob("c:/Program Files/ImageMagick-*.**").sort!
    imHome = imPaths[imPaths.size-1]
    FileUtils.mkdir_p("#{build_dir}/bin/")
    if imHome.include?("-6") then
      FileUtils.cp("#{imHome}/CORE_RL_magick_.dll", "#{build_dir}/bin/")
      FileUtils.cp("#{imHome}/CORE_RL_Magick++_.dll", "#{build_dir}/bin/")
      FileUtils.cp("#{imHome}/CORE_RL_wand_.dll", "#{build_dir}/bin/")
    else
      FileUtils.cp("#{imHome}/CORE_RL_MagickCore_.dll", "#{build_dir}/bin/")
      FileUtils.cp("#{imHome}/CORE_RL_Magick++_.dll", "#{build_dir}/bin/")
      FileUtils.cp("#{imHome}/CORE_RL_MagickWand_.dll", "#{build_dir}/bin/")
    end
    puts @name
    if @name == 'host'
      if imHome.include?("-6")  then
        FileUtils.cp("#{imHome}/CORE_RL_magick_.dll", "#{MRUBY_ROOT}/bin/")
        FileUtils.cp("#{imHome}/CORE_RL_Magick++_.dll", "#{MRUBY_ROOT}/bin/")
        FileUtils.cp("#{imHome}/CORE_RL_wand_.dll", "#{MRUBY_ROOT}/bin/")  
      else 
        FileUtils.cp("#{imHome}/CORE_RL_MagickCore_.dll", "#{MRUBY_ROOT}/bin/")
        FileUtils.cp("#{imHome}/CORE_RL_Magick++_.dll", "#{MRUBY_ROOT}/bin/")
        FileUtils.cp("#{imHome}/CORE_RL_MagickWand_.dll", "#{MRUBY_ROOT}/bin/")  
      end

    end
  end
end