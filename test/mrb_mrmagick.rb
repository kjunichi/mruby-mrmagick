##
## Mrmagick Test
##
def setupTestImage
  `convert -size 640x480 -background "#C0C0C0" -fill "#FFFF00" caption:"ABC" output.png`
end

def tearDownTestImage
  `rm -f t.png dest.png diff.png output.png`
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
  t.gsub!("\n","")
  assert_equal("0",t)
  tearDownTestImage
end

assert("Mrmagick::Image#blur_image") do
  setupTestImage
  Mrmagick::ImageList.new("output.png").blur_image(1.0,8.0).write("t.png")
  `convert -blur 1.0x8.0 output.png dest.png`
  `composite -compose difference dest.png t.png diff.png`
  t= `identify -format "%[mean]" diff.png`
  t.gsub!("\n","")
  assert_equal("0",t)
  tearDownTestImage
end

assert("Mrmagick::Image#rotate") do
  setupTestImage
  Mrmagick::ImageList.new("output.png").rotate(30).write("t.png")
  `convert -rotate 30 output.png dest.png`
  `composite -compose difference dest.png t.png diff.png`
  t= `identify -format "%[mean]" diff.png`
  t.gsub!("\n","")
  assert_equal("0",t)
  tearDownTestImage
end

assert("Mrmagick::Image#flop") do
  setupTestImage
  Mrmagick::ImageList.new("output.png").flop.write("t.png")
  `convert -flop output.png dest.png`
  `composite -compose difference dest.png t.png diff.png`
  t= `identify -format "%[mean]" diff.png`
  t.gsub!("\n","")
  assert_equal("0",t)
  tearDownTestImage
end

assert("Mrmagick::Image#flip") do
  setupTestImage
  Mrmagick::ImageList.new("output.png").flip.write("t.png")
  `convert -flip output.png dest.png`
  `composite -compose difference dest.png t.png diff.png`
  t= `identify -format "%[mean]" diff.png`
  t.gsub!("\n","")
  assert_equal("0",t)
  tearDownTestImage
end

assert("Mrmagick::Image#orientation") do
  setupTestImage
  o = Mrmagick::ImageList.new("output.png").orientation
  assert_equal("",o)
  t = Mrmagick::ImageList.new("output.png")
  t.orientation=1
  t.write("t.png")
  t = Mrmagick::ImageList.new("t.png")
  assert_equal("1",t.orientation)
  t = Mrmagick::ImageList.new("output.png")
  t.orientation=7
  t.write("t.jpg")
  t = Mrmagick::ImageList.new("t.jpg")
  assert_equal("7",t.orientation)
  tearDownTestImage
end

assert("Mrmagick::Image#auto_orient") do
  setupTestImage
  o = Mrmagick::ImageList.new("output.png")
  o.orientation=5
  o.write("t.jpg")
  t = Mrmagick::ImageList.new("t.jpg")
  t=t.auto_orient
  t.write("t.jpg")
  t = Mrmagick::ImageList.new("t.jpg")
  assert_equal("1",t.orientation)
  tearDownTestImage
end

assert("Mrmagick::ImageList#bye") do
  assert_equal("bye", Mrmagick::ImageList.bye)
end

assert("Mrmagick::Capi.hi") do
  assert_equal("hi!!", Mrmagick::Capi.hi)
end
