# EV0001 Bot - Copyright 2011 vgvgf

class Log
	def initialize(folder)
		@folder = folder
		@logs = {}
		if !folder.empty? && !File.directory?(folder)
			FileUtils.mkdir_p(folder)
		end
	end

	def write_header(filename)
		return if File.exists?(filename)
		File.open(filename, 'wb') do |f|
			f.write([0xef, 0xbb, 0xbf].pack("C*")) # UTF-8 Header
		end
	end

	def write_log
		if !@logs.empty?
			@logs.each do |filename, file_logs|
				write_header(filename)
				File.open(filename, 'a+') do |f|
					text = ""
					until file_logs.empty?
						text << file_logs.slice!(0)
						text << "\r\n"
					end
					#text << "</body></html>"
					f.write(text)
				end
			end
			@logs.clear
		end
	end

	def add_log(str)
		filename = Time.new.strftime("#{@folder}#{@file}")
		@logs[filename] = [] if !@logs.has_key?(filename)
		@logs[filename] << str
	end
end
