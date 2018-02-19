##
## Mrmagick Test
##
def setupTestImage
  `convert -size 640x480 -background "#C0C0C0" -fill "#FFFF00" caption:"ABC" output.png`
end

def tearDownTestImage
  `rm -f t.png dest.png dest*.gif diff.png output.png`
end

assert('Mrmagick::Image#scale') do
  setupTestImage
  Mrmagick::ImageList.new('output.png').scale(0.5).write('t.png')
  `convert -scale 50% output.png dest.png`
  `composite -compose difference dest.png t.png diff.png`
  t = `identify -format "%[mean]" diff.png`
  t.gsub!("\n","")
  assert_equal('0', t)
  tearDownTestImage
end

assert('Mrmagick::Image#blur_image') do
  setupTestImage
  Mrmagick::ImageList.new('output.png').blur_image(1.0, 8.0).write('t.png')
  `convert -blur 1.0x8.0 output.png dest.png`
  `composite -compose difference dest.png t.png diff.png`
  t = `identify -format "%[mean]" diff.png`
  t.gsub!("\n","")
  assert_equal('0', t)
  tearDownTestImage
end

assert('Mrmagick::Image#rotate') do
  setupTestImage
  Mrmagick::ImageList.new('output.png').rotate(30).write('t.png')
  `convert -rotate 30 output.png dest.png`
  `composite -compose difference dest*.png t.png diff.png`
  t = `identify -format "%[mean]" diff.png`
  t.gsub!("\n","")
  assert_equal('0', t)
  tearDownTestImage
end

assert('Mrmagick::Image#flop') do
  setupTestImage
  Mrmagick::ImageList.new('output.png').flop.write('t.png')
  `convert -flop output.png dest.png`
  `composite -compose difference dest.png t.png diff.png`
  t = `identify -format "%[mean]" diff.png`
  t.gsub!("\n","")
  assert_equal('0', t)
  tearDownTestImage
end

assert('Mrmagick::Image#flip') do
  setupTestImage
  Mrmagick::ImageList.new('output.png').flip.write('t.png')
  `convert -flip output.png dest.png`
  `composite -compose difference dest.png t.png diff.png`
  t = `identify -format "%[mean]" diff.png`
  t.gsub!("\n","")
  assert_equal('0', t)
  tearDownTestImage
end

assert('Mrmagick::Image#orientation') do
  setupTestImage
  o = Mrmagick::ImageList.new('output.png').orientation
  assert_equal('', o)
  t = Mrmagick::ImageList.new('output.png')
  t.orientation = 1
  t.write('t.png')
  t = Mrmagick::ImageList.new('t.png')
  
  # for ImageMagick v7
  result = t.orientation
  result = '1' if result == ""
  assert_equal('1', result)

  t = Mrmagick::ImageList.new('output.png')
  t.orientation = 7
  t.write('t.jpg')
  t = Mrmagick::ImageList.new('t.jpg')
  assert_equal('7', t.orientation)
  tearDownTestImage
end

assert('Mrmagick::Image#auto_orient') do
  setupTestImage
  o = Mrmagick::ImageList.new('output.png')
  o.orientation = 5
  o.write('t.jpg')
  t = Mrmagick::ImageList.new('t.jpg')
  t = t.auto_orient
  t.write('t.jpg')
  t2 = t.rotate(123)
  assert_equal('1', t2.orientation)
  t = Mrmagick::ImageList.new('t.jpg')
  assert_equal('1', t.orientation)
  tearDownTestImage
end

assert('Mrmagick::Image#write') do
  setupTestImage
  o = Mrmagick::ImageList.new('output.png')
  o2 = o.rotate(180)
  o3 = o.blur_image(1.0, 8.0)
  o.push o2
  o.push o3
  o.write('dest.gif')
  `convert +adjoin dest.gif dest.gif`
  `convert output.png dest.gif`
  `composite -compose difference dest-0.gif dest.gif diff.png`
  t = `identify -format "%[mean]" diff.png`
  t.gsub!("\n","")
  assert_equal('0', t)
  `convert -rotate 180 output.png dest.gif`
  `composite -compose difference dest-1.gif dest.gif diff.png`
  t = `identify -format "%[mean]" diff.png`
  t.gsub!("\n","")
  assert_equal('0', t)
  `convert -blur 1.0x8.0 output.png dest.gif`
  `composite -compose difference dest-2.gif dest.gif diff.png`
  t = `identify -format "%[mean]" diff.png`
  t.gsub!("\n","")

  # for ImageMagick v7
  t = "0" if t.to_f < 0.003
  assert_equal('0', t)
  
  tearDownTestImage
end

assert('Mrmagick::Image#columns') do
  setupTestImage
  o = Mrmagick::ImageList.new('output.png')
  assert_equal(640, o.columns)
  tearDownTestImage
end

assert("Mrmagick::Image#rows") do
  setupTestImage
  o = Mrmagick::ImageList.new('output.png')
  assert_equal(480, o.rows)
  tearDownTestImage
end

assert('Mrmagick::Image#format') do
  setupTestImage
  o = Mrmagick::ImageList.new('output.png')
  assert_equal('Portable Network Graphics', o.format)
  o.write('dest.gif')
  o = Mrmagick::ImageList.new('dest.gif')
  assert_equal('CompuServe graphics interchange format', o.format)
  tearDownTestImage
end

assert('Mrmagick::Image#crop') do
  setupTestImage
  Mrmagick::ImageList.new('output.png').crop(8, 16, 256, 384).write('t.png')
  `convert -crop 256x384+8+16! output.png dest.png`
  `composite -compose difference dest.png t.png diff.png`
  t = `identify -format "%[mean]" diff.png`
  t.gsub!("\n","")
  assert_equal('0', t)

  tearDownTestImage
end

assert("Mrmagick::ImageList#from_blob") do
  setupTestImage
  #if ENV['VisualStudioVersion'] || ENV['VSINSTALLDIR'] then
  #  imgData = `type output.png`
  #else
  #  imgData = `cat output.png`
  #end
  #p imgData.length
  #img1 = Mrmagick::ImageList.new()
  #img1.from_blob(imgData)
  #img2 = Mrmagick::ImageList.new("output.png")
    #assert_equal(img1,img2)
  #assert_equal(img1.rows,img2.rows)
  #assert_equal(img1.columns,img2.columns)
  tearDownTestImage
end
