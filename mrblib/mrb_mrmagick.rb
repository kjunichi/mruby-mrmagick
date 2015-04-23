module Mrmagick
	class Magickcmd
		def initialize(cmd)
		end
	end
	class Image
		def initialize(path)
			@origImagePath = path
      p @origImagePath
      return self
		end

    def magickCommand(cmd)
      @cmd = cmd
    end

		def blur_image(param)
			destImage = Image.new
			destImage.magickCommand("convert #{self.gen} -blur #{param} ")
			return destImage
		end

		def write(path)
			# これまでのコマンドを実行する。
      put @cmd
		end
		def gen
			# 自分を出力する。
			if @origImagePath.length > 0 then
				return @origImagePath
      else

			end
		end
		def destroy!
			# 内部で隠し持ってた情報を全部ばれないように証拠隠滅する。
		end

	end
	class ImageList
    def initialize
      @cmd=""
    end
		def initialize(imagePath)
      puts "ImageList.new start"
			@image = Mrmagick::Image.new(imagePath)
      @cmd=""
		end

    def setCommand(cmd)
      @cmd=cmd
    end

    def blur_image(param)
			destImage = ImageList.new ""
      srcImagePath=@image.gen
			destImage.setCommand("convert #{srcImagePath} -blur #{param} ")
			return destImage
		end

    def self.bye
			#self.hello + " bye"
			"bye"
		end
	end
	class Draw

	end
end
