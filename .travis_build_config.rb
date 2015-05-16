MRuby::Build.new do |conf|
  toolchain :gcc
  conf.gembox 'full-core'
  conf.gem :git => 'https://github.com/iij/mruby-io.git'

  conf.gem '../mruby-mrmagick'
end
