##
## Mrmagick Test
##
def setupTestImage
  `convert -size 640x480 -background "#C0C0C0" -fill "#FFFF00" caption:"ABC" output.png`
end

def tearDownTestImage
  `rm t.png dest.png diff.png output.png`
end

assert("Mrmagick::Capi#hello") do
  t = Mrmagick::Capi.new "hello"
  assert_equal("hello", t.hello)
end

assert("Mrmagick::Image#scale") do
  setupTestImage
  Mrmagick::ImageList.new("output.png").scale(0.5).write("t.png")
  `convert -scale 50% output.png dest.png`
  `composite -compose difference dest.png t.png diff.png`
  t= `identify -format "%[mean]" diff.png`
  assert_equal("0",t)
  tearDownTestImage
end

assert("Mrmagick::Image#blur_image") do
  setupTestImage
  Mrmagick::ImageList.new("output.png").blur_image(1.0,8.0).write("t.png")
  `convert -blur 1.0x8.0 output.png dest.png`
  `composite -compose difference dest.png t.png diff.png`
  t= `identify -format "%[mean]" diff.png`
  assert_equal("0",t)
  tearDownTestImage
end

assert("Mrmagick::ImageList#bye") do
  assert_equal("bye", Mrmagick::ImageList.bye)
end

assert("Mrmagick::Capi.hi") do
  assert_equal("hi!!", Mrmagick::Capi.hi)
end
