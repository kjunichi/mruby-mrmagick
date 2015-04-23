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
p Mrmagick.hi
#=> "hi!!"
t = Mrmagick.new "hello"
p t.hello
#=> "hello"
p t.bye
#=> "hello bye"
```

## License
under the MIT License:
- see LICENSE file
