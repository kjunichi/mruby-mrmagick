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
					if c.include?("-resize") then
						params = c.split(" ")
						#p params
						Mrmagick::Capi.scale(params[1], params[4], params[3])
					elsif c.include?("-blur") then
						params = c.split(" ")
						radius_sigma=params[3].split(",")

						p radius_sigma
						if radius_sigma.length<2 then
							sigma = 0.5
						else
							sigma = radius_sigma[1].to_f;
						end
						#p radius_sigma[0],sigma
						Mrmagick::Capi.blur(params[1], params[4], radius_sigma[0].to_f, sigma)
					else
							rtn = `#{c}`
					end
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
				if !scale.to_s.include?("%") then
					scale = scale * 100
					param = scale.to_s + "%"
				else
					param = scale
				end

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
