module Mrmagick
	class Magickcmd
		def initialize(cmd)
		end
	end
	class Image
		def initialize(path)
			@origImagePath = path
			p @origImagePath
			#return self
		end

		def setParentImage(images)
			@images.push(images)
			@images.flatten!
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
				#puts @origImagePath
			else
				# これまでのコマンドを実行する。
				lastIdx = @cmd.size-1
				idx=0
				# 削除ファイルリスト
				delTmpFiles=[]
				for c in @cmd do

					if idx == lastIdx then
						p idx
						p @origImagePath,path
						c.gsub!(@origImagePath, path)
					end
					puts c
					params = c.split(" ")
					if idx<lastIdx and lastIdx>0 then
						# 複数処理する場合、中間ファイルは削除対象にする。
						delTmpFiles.push(params[4])
					end
					if c.include?("-resize") then
						Mrmagick::Capi.scale(params[1], params[4], params[3])
					elsif c.include?("-blur") then
						radius_sigma=params[3].split(",")
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
					idx = idx + 1
				end
					if delTmpFiles.size>0 then
						Mrmagick::Capi.rm(delTmpFiles)
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

			if imagePath.length == 0 then
				# 物理パスが指定されていない場合、仮想的にファイル名を生成し、保持する。
				#path = `uuidgen`.chomp!
				path = Mrmagick::Capi.uuid()
				imagePath = path+".png"
				@fRealFile = false
			else
				@fRealFile = true
			end
			@images=[]

			@image = Mrmagick::Image.new(imagePath)
			@cmd=""
		end

		def setParentImages(images)
			@images.push(images)
			@images.flatten!

		end

		def getPath
			return @image.gen
		end
		def write(path)
			@image.write(path)
		end

		def magickCommand(cmd)
			#puts "magickCommand"
			puts cmd
			@images.each {|savedCmd|
				@image.magickCommand(savedCmd)
			}
			@image.magickCommand(cmd)
			@images.push(cmd)
		end

		def createVirtualImageList()
			destImage = ImageList.new ""
			destImage.setParentImages(@images)
			return destImage
		end

		def blur_image(*args)
			param = args.join(',')
			destImage = createVirtualImageList()
			srcImagePath=@image.gen
			destImage.magickCommand("convert #{srcImagePath} -blur #{param} #{destImage.getPath}")
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
			destImage = createVirtualImageList()
			srcImagePath=@image.gen
			destImage.magickCommand("convert #{srcImagePath} -resize #{param} #{destImage.getPath}")
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
