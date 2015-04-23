##
## Mrmagick Test
##

assert("Mrmagick::Capi#hello") do
  t = Mrmagick::Capi.new "hello"
  assert_equal("hello", t.hello)
end

assert("Mrmagick::ImageList#bye") do
  assert_equal("bye", Mrmagick::ImageList.bye)
end

assert("Mrmagick::Capi.hi") do
  assert_equal("hi!!", Mrmagick::Capi.hi)
end
