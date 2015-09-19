module Mrmagick
  class Magickcmd
    def initialize(_cmd)
    end
  end
  class Image
    def initialize(path)
      @origImagePath = path
      p @origImagePath
      # return self
    end

    def setParentPath(path)
      @parentPath = path
    end

    def get_exif_by_entry(key)
      @exifKey = key
      Mrmagick::Capi.get_exif_by_entry(self)
    end

    def setParentImage(images)
      @images.push(images)
      @images.flatten!
    end

    def magickCommand(cmd)
      if @cmd.nil?
        # １番目のコマンドのソースパスを親のパス(実体のある画像ファイル)と仮定。
        params = cmd.split(' ')
        @parentPath = params[1]
        @cmd = [cmd]
      else
        @cmd.push(cmd)
      end
    end

    def from_blob(blob)
      Mrmagick::Capi.from_blob(self, blob)
    end

    def to_blob
      Mrmagick::Capi.to_blob(self)
    end

    def write(path)
      @outpath = path
      Mrmagick::Capi.write(self)
    end

    def write_old(path)
      if @cmd.nil?
      # からのファイルを作る？
      # puts @origImagePath
      else
        # これまでのコマンドを実行する。
        lastIdx = @cmd.size - 1
        idx = 0
        # 削除ファイルリスト
        delTmpFiles = []
        for c in @cmd do
          if idx == lastIdx
            p idx
            p @origImagePath, path
            c.gsub!(@origImagePath, path)
          end
          puts c
          params = c.split(' ')
          if idx < lastIdx && lastIdx > 0
            # 複数処理する場合、中間ファイルは削除対象にする。
            delTmpFiles.push(params[4])
          end
          if c.include?('-resize')
            Mrmagick::Capi.scale(params[1], params[4], params[3])
          elsif c.include?('-blur')
            radius_sigma = params[3].split(',')
            if radius_sigma.length < 2
              sigma = 0.5
            else
              sigma = radius_sigma[1].to_f
            end
            # p radius_sigma[0],sigma
            Mrmagick::Capi.blur(params[1], params[4], radius_sigma[0].to_f, sigma)
          else
            rtn = `#{c}`
          end
          idx += 1
        end
        Mrmagick::Capi.rm(delTmpFiles) if delTmpFiles.size > 0
      end
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
    def initialize
    end

    def initialize(imagePath)
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
    end

    def get_exif_by_entry(key)
      @image.get_exif_by_entry(key)
    end

    def setParentImages(images)
      @images.push(images)
      @images.flatten!
    end

    def getPath
      @image.gen
    end

    def write(path)
      @image.write(path)
    end

    def to_blob
      @image.to_blob
    end

    def from_blob(blob)
      @image.from_blob(blob)
    end

    def magickCommand(cmd)
      # puts "magickCommand"
      puts cmd
      @images.each do|savedCmd|
        @image.magickCommand(savedCmd)
      end
      @image.magickCommand(cmd)
      @images.push(cmd)
    end

    def createVirtualImageList
      destImage = ImageList.new ''
      destImage.setParentImages(@images)
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

    def self.bye
      # self.hello + " bye"
      'bye'
    end
  end
  class Draw
  end
end
