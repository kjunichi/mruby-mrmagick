##
## Mrmagick Test
##

assert("Mrmagick#hello") do
  t = Mrmagick.new "hello"
  assert_equal("hello", t.hello)
end

assert("Mrmagick#bye") do
  t = Mrmagick.new "hello"
  assert_equal("hello bye", t.bye)
end

assert("Mrmagick.hi") do
  assert_equal("hi!!", Mrmagick.hi)
end
