MRuby::Build.new do |conf|
  toolchain :visualcpp
  conf.gembox 'default'
  conf.gem '../mruby-mrmagick'
  conf.enable_test
end
