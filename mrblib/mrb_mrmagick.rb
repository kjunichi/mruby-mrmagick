module Mrmagick
  class Magickcmd
    def initialize(_cmd)
    end
  end
  class Image
    def initialize(path)
      @origImagePath = path
      @exif = {}
      @isBlob = false
      # p @origImagePath
      # return self
    end

    def setParentPath(path)
      @parentPath = path
    end

    # Get width of the image.
    #
    # @return [Integer] width of the image.
    def columns
      Mrmagick::Capi.get_columns(self)
    end

    # Get height of the image.
    #
    # @return [Integer] height of the image.
    def rows
      Mrmagick::Capi.get_rows(self)
    end

    # Get format of the image.
    #
    # @return [String] format of the image.
    def format
      Mrmagick::Capi.get_format(self)
    end

    # Crop the image.
    #
    # @param [Integer] offset_x offset x.
    # @param [Integer] offset_y offset y.
    # @param [Integer] width width.
    # @param [Integer] height height.
    # @return [Image] cropped image.
    def crop(offset_x, offset_y, width, height)
      destImage = ImageList.createVirtualImageList
      srcImagePath = gen
      destImage.magickCommand("convert #{srcImagePath} -crop #{width}x#{height}+#{offset_x}+#{offset_y} #{destImage.getPath}")
      destImage
    end

    def get_exif_by_entry(key)
      @exifKey = key
      Mrmagick::Capi.get_exif_by_entry(self)
    end

    def set_exif_by_entry(key, value)
      @exif[key] = value
    end

    def setParentImage(images)
      @images.push(images)
      @images.flatten!
    end

    # Chcek cached Orientation
    #
    # @return [Boolean] has orientation.
    def hasCachedOrientation
      if @exif["Orientation"]==nil
        return false
      end
      return true
    end

    # Set parent orientation
    #
    # @param [Image] parent image.
    def setParentOrientation(img)
      if img.hasCachedOrientation
        @orientationv = img.orientation.to_i
        @exif["Orientation"]=img.orientation
      end
    end

    def magickCommand(cmd)
      if @cmd.nil?
        # １番目のコマンドのソースパスを親のパス(実体のある画像ファイル)と仮定。
        params = cmd.split(' ')
        @parentPath = params[1]
        @cmd = [cmd]
      else
        @cmd.push(cmd)
        # p self
      end
    end

    def from_blob(blob)
      @isBlob = true
      @blob = blob
      #Mrmagick::Capi.from_blob(self, blob)
    end

    def to_blob
      Mrmagick::Capi.to_blob(self)
    end

    def write(path)
      @outpath = path
      Mrmagick::Capi.write(self)
    end

    def rotate(rot)
      destImage = ImageList.createVirtualImageList
      srcImagePath = gen
      # p srcImagePath
      destImage.magickCommand("convert #{srcImagePath} -rotate #{rot} #{destImage.getPath}")
      destImage
    end

    def flop
      destImage = ImageList.createVirtualImageList
      srcImagePath = gen
      destImage.magickCommand("convert #{srcImagePath} -flop #{destImage.getPath}")
      destImage
    end

    def flip
      # p "flip"
      destImage = ImageList.createVirtualImageList
      srcImagePath = gen
      destImage.magickCommand("convert #{srcImagePath} -flip #{destImage.getPath}")
      destImage
    end

    def transpose
      destImage = createVirtualImageList
      srcImagePath = gen
      destImage.magickCommand("convert #{srcImagePath} -rotate 90 #{destImage.getPath}")
      destImage.magickCommand("convert #{srcImagePath} -flop #{destImage.getPath}")
      destImage
    end

    def transverse
      destImage = createVirtualImageList
      srcImagePath = gen
      destImage.magickCommand("convert #{srcImagePath} -rotate 270 #{destImage.getPath}")
      destImage.magickCommand("convert #{srcImagePath} -flop #{destImage.getPath}")
      destImage
    end

    def orientation=(v)
      @exif["Orientation"] = v.to_s
      @orientationv = v
    end

    def orientation
      @exifKey = 'Orientation'
      if(@exif[@exifKey]!=nil && @exif[@exifKey]!="")
        return @exif[@exifKey]
      end
      #p "get real orientation!"
      orient = Mrmagick::Capi.get_exif_by_entry(self)
      @exif[@exifKey]=orient
      orient
    end

    def auto_orient
      orient = orientation
      case orient
      when '2' then
        destImage = flop
      when '3' then
        destImage = rotate(180)
      when '4' then
        destImage = flip
      when '5' then
        destImage = transpose
      when '6' then
        destImage = rotate(90)
      when '7' then
        destImage = transverse
      when '8' then
        destImage = roteate(270)
      else
        destImage = rotate(0)
      end
      destImage.orientation = 1
      destImage
    end

    def gen
      # 自分のファイルパスを出力する。
      return @origImagePath if @origImagePath.length > 0
    end

    def destroy!
      # 内部で隠し持ってた情報を全部ばれないように証拠隠滅する。
    end
  end
  class ImageList

    def initialize(*args)
      if(args.length==0)
        imagePath = ""
      else
        imagePath = args[0]
      end

      if imagePath.length == 0
        # 物理パスが指定されていない場合、仮想的にファイル名を生成し、保持する。
        # path = `uuidgen`.chomp!
        # path = Mrmagick::Capi.uuid()
        path = 'nofilepath'
        imagePath = path + '.png'
        @fRealFile = false
      else
        @fRealFile = true
        srcImagePath = imagePath
      end
      @images = []

      @image = Mrmagick::Image.new(imagePath)
      @image.setParentPath(imagePath)
      @cmd = ''
      @frames = []
    end

    def get_exif_by_entry(key)
      @image.get_exif_by_entry(key)
    end

    def set_exif_by_entry(key, value)
      @image.set_exif_by_entry(key, value)
    end

    def orientation=(v)
      @image.orientation = v
    end

    def orientation
      @image.orientation
    end

    def auto_orient
      orient = orientation
      case orient
      when '2' then
        destImage = flop
      when '3' then
        destImage = rotate(180)
      when '4' then
        destImage = flip
      when '5' then
        destImage = transpose
      when '6' then
        destImage = rotate(90)
      when '7' then
        destImage = transverse
      when '8' then
        destImage = rotate(270)
      else
        destImage = rotate(0)
      end
      #p "ImageList.auto_orient set "
      destImage.orientation = 1
      destImage
    end

    def setParentImages(images)
      @images.push(images)
      @images.flatten!
    end

    # Set parent orientation
    #
    # @param [Image] parent image.
    def setParentOrientation(img)
      @image.setParentOrientation(img)
    end

    def getPath
      @image.gen
    end

    def write(path)
      if path.split('.')[-1] == 'gif'
        # p @frames.length
        if @frames.length > 0
          # 複数のImageからblobを取り出し、これをgifとして保存する。
          blobs = []
          if(@fRealFile)
            blobs.push(@image.to_blob)
          end
          @frames.each do|imglist|
            blobs.push(imglist.to_blob)
          end
          # p blobs.length
          Mrmagick::Capi.write_gif(path, blobs)
        else
          @image.write(path)
        end
      else
        if(@fRealFile)
          @image.write(path)
        else
          blobs = []
          @frames.each do|imglist|
            blobs.push(imglist.to_blob)
          end
          if(blobs.length > 0)
            Mrmagick::Capi.write_gif(path, blobs)
          else
            @image.write(path)
          end
        end
      end
    end

    def to_blob
      @image.to_blob
    end

    def from_blob(blob)
      @image.from_blob(blob)
    end

    def magickCommand(cmd)
      # puts "magickCommand: " + cmd

      @images.each do|savedCmd|
        # puts "savedCmd: " + savedCmd
        @image.magickCommand(savedCmd)
      end
      @image.magickCommand(cmd)
      @images.push(cmd)
    end

    def magickCommand2(cmd)
      # puts "magickCommand2: " + cmd
      @image.magickCommand(cmd)
      @images.push(cmd)
    end

    def createVirtualImageList
      destImage = ImageList.new ''
      destImage.setParentImages(@images)
      destImage.setParentOrientation(@image)
      destImage
    end

    def blur_image(*args)
      param = args.join(',')
      destImage = createVirtualImageList
      srcImagePath = @image.gen
      destImage.magickCommand("convert #{srcImagePath} -blur #{param} #{destImage.getPath}")
      destImage
    end

    def scale(*args)
      if args.length > 1
        param = args.join('x')
      else
        scale = args[0]
        if !scale.to_s.include?('%')
          scale *= 100
          param = scale.to_s + '%'
        else
          param = scale
        end
      end
      destImage = createVirtualImageList
      srcImagePath = @image.gen
      destImage.magickCommand("convert #{srcImagePath} -resize #{param} #{destImage.getPath}")
      destImage
    end

    def rotate(rot)
      destImage = createVirtualImageList
      srcImagePath = @image.gen
      destImage.magickCommand("convert #{srcImagePath} -rotate #{rot} #{destImage.getPath}")
      destImage
    end

    def flop
      destImage = createVirtualImageList
      srcImagePath = @image.gen
      destImage.magickCommand("convert #{srcImagePath} -flop #{destImage.getPath}")
      destImage
    end

    def flip
      destImage = createVirtualImageList
      srcImagePath = @image.gen
      destImage.magickCommand("convert #{srcImagePath} -flip #{destImage.getPath}")
      destImage
    end

    def transpose
      destImage = createVirtualImageList
      srcImagePath = @image.gen
      destImage.magickCommand("convert #{srcImagePath} -rotate 90 #{destImage.getPath}")
      destImage.magickCommand2("convert #{srcImagePath} -flop #{destImage.getPath}")
      destImage
    end

    def transverse
      destImage = createVirtualImageList
      srcImagePath = @image.gen
      destImage.magickCommand("convert #{srcImagePath} -rotate 270 #{destImage.getPath}")
      destImage.magickCommand2("convert #{srcImagePath} -flop #{destImage.getPath}")
      destImage
    end

    # Crop the image.
    #
    # @param [Integer] offset_x offset x.
    # @param [Integer] offset_y offset y.
    # @param [Integer] width width.
    # @param [Integer] height height.
    # @return [Image] cropped image.
    def crop(offset_x, offset_y, width, height)
      destImage = createVirtualImageList
      srcImagePath = @image.gen
      if offset_x>0
        xOffSgnStr = "+"
      else
        xOffSgnStr = "-"
        offset_x = - offset_x
      end

      if offset_y>0
        yOffSgnStr = "+"
      else
        yOffSgnStr = "-"
        offset_y = - offset_y
      end
      destImage.magickCommand("convert #{srcImagePath} -crop #{width}x#{height}"+xOffSgnStr+"#{offset_x}"+yOffSgnStr+"#{offset_y}! #{destImage.getPath}")
      destImage
    end

    # Get width of the image.
    #
    # @return [Integer] width of the image.
    def columns
      @image.columns
    end

    # Get height of the image.
    #
    # @return [Integer] height of the image.
    def rows
      @image.rows
    end

    # Get format of the image.
    #
    # @return [String] format of the image.
    def format
      @image.format
    end

    def getImage
      @image
    end

    def push(images)
      @frames.push(images)
    end
  end
  class Draw
  end

  def self.formats(&blk)
    #puts "formats"
    h = self.capi_formats
    if blk then
      h.each {|item|
        blk.call(item)
      }
    else 
      return h
    end
  end
end
