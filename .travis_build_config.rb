MRuby::Build.new do |conf|
  toolchain :gcc
  conf.gembox 'full-core'
  conf.disable_cxx_exception
  conf.gem '../mruby-mrmagick'
end

MRuby::Build.new('test') do |conf|
  toolchain :gcc

  enable_debug
  conf.disable_cxx_exception
  conf.enable_bintest
  conf.enable_test

  conf.gembox 'full-core'
  
  conf.gem :github => 'iij/mruby-io.git'
  conf.gem '../mruby-mrmagick'
end
