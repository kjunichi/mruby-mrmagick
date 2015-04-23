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
			if @cmd.nil? then
				@cmd=[cmd]
			else
				@cmd.push(cmd)
			end
		end

		def write(path)
			if @cmd.nil? then
				# からのファイルを作る？
				puts @origImagePath
			else
				# これまでのコマンドを実行する。
				lastIdx = @cmd.size-1
				idx=0
				for c in @cmd do
					if idx == lastIdx then
						c.gsub!(@origImagePath, path)
					end
					puts c
					#rtn = `c`
				end
			end
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

		end
		def initialize(imagePath)
			puts "ImageList.new start"
			if imagePath.length == 0 then
				path = `uuidgen`.chomp!
				imagePath = path+".png"
			end
			@image = Mrmagick::Image.new(imagePath)
			@cmd=""
		end
				def getPath
			return @image.gen
		end
		def write(path)
			@image.write(path)
		end

		def magickCommand(cmd)
			puts "magickCommand"
			puts cmd
			@image.magickCommand(cmd)
		end

		def blur_image(*args)
			param = args.join(',')
			destImage = ImageList.new ""
			destImagePath = destImage.getPath
			srcImagePath=@image.gen
			destImage.magickCommand("convert #{srcImagePath} -blur #{param} #{destImagePath}")
			return destImage
		end

		def scale(*args)
			if args.length >1 then
				param = args.join('x')
			else
				scale = args[0]
				if scale<1 then
					scale = scale * 100
				end
				param = scale + "%"
			end
			destImage = ImageList.new ""
			destImagePath = destImage.getPath
			srcImagePath=@image.gen
			destImage.magickCommand("convert #{srcImagePath} -resize #{param} #{destImagePath}")
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
