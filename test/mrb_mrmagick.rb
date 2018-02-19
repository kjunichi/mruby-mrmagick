##
## Mrmagick Test
##
def setupTestImage
  `convert -size 640x480 -background "#C0C0C0" -fill "#FFFF00" caption:"ABC" output.png`
end

def tearDownTestImage
  `rm -f t.png dest.png dest*.gif diff.png output.png`
  #`del /Q t.png dest.png dest*.gif diff.png output.png`
end

assert('Mrmagick::Image#scale') do
  setupTestImage
  #Mrmagick::ImageList.new('output.png').scale(0.5).write('t.png')
  #`convert -scale 50% output.png dest.png`
  #`composite -compose difference dest.png t.png diff.png`
  #t = `identify -format "%[mean]" diff.png`
  #t.gsub!("\n","")
  #assert_equal('0', t)
  tearDownTestImage
end

