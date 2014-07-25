# EV0001 Bot - Copyright 2011 vgvgf

class ChannelLog < Log
	def initialize(channel)
		super("#{LOG_PATH}#{channel}/")
		@file = '%Y-%m-%d.html'
		@channel = channel
	end

	def write_header(filename)
		return if File.exists?(filename)
		super(filename)

		File.open(filename, 'w') do |f|
			header = "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n"
			header << "<html>\n"
			header << "<head>\n"
			header << "\t<meta http-equiv=\"content-type\" content=\"text/html; charset=iso-8859-1\" />\n"
			header << Time.new.strftime("\t<title>##{@channel} IRC logs [%B %d - %Y]</title>\n")
			header << "\t<style>\n"
			header << "\t\tbody { margin: 10px; padding: 10px; background-color: #ffffff; font: 12px/16px Verdana, Arial, Helvetica; }\n"
			header << "\t\t.m { color: #404040; }\n" # Message
			header << "\t\t.j { color: #009200; }\n" # Join
			header << "\t\t.q { color: #800000; }\n" # Quit
			header << "\t\t.n { color: #bb8800; }\n" # Nick change
			header << "\t\t.a { color: #9c009c; }\n" # Action
			header << "\t\t.o { color: #bb8800; }\n" # Mode
			header << "\t\t.c0 { color: #FFFFFF; }\n"
			header << "\t\t.c1 { color: #000000; }\n"
			header << "\t\t.c2 { color: #000080; }\n"
			header << "\t\t.c3 { color: #008000; }\n"
			header << "\t\t.c4 { color: #FF0000; }\n"
			header << "\t\t.c5 { color: #804040; }\n"
			header << "\t\t.c6 { color: #8000FF; }\n"
			header << "\t\t.c7 { color: #808000; }\n"
			header << "\t\t.c8 { color: #FFFF00; }\n"
			header << "\t\t.c9 { color: #00FF00; }\n"
			header << "\t\t.c10 { color: #008080; }\n"
			header << "\t\t.c11 { color: #00FFFF; }\n"
			header << "\t\t.c12 { color: #0000FF; }\n"
			header << "\t\t.c13 { color: #FF00FF; }\n"
			header << "\t\t.c14 { color: #808080; }\n"
			header << "\t\t.c15 { color: #C0C0C0; }\n"
			header << "\t\t.bc1 { background-color: #000000; }\n"
			header << "\t\t.bc0 { background-color: #FFFFFF; }\n"
			header << "\t\t.bc2 { background-color: #000080; }\n"
			header << "\t\t.bc3 { background-color: #008000; }\n"
			header << "\t\t.bc4 { background-color: #FF0000; }\n"
			header << "\t\t.bc5 { background-color: #804040; }\n"
			header << "\t\t.bc6 { background-color: #8000FF; }\n"
			header << "\t\t.bc7 { background-color: #808000; }\n"
			header << "\t\t.bc8 { background-color: #FFFF00; }\n"
			header << "\t\t.bc9 { background-color: #00FF00; }\n"
			header << "\t\t.bc10 { background-color: #008080; }\n"
			header << "\t\t.bc11 { background-color: #00FFFF; }\n"
			header << "\t\t.bc12 { background-color: #0000FF; }\n"
			header << "\t\t.bc13 { background-color: #FF00FF; }\n"
			header << "\t\t.bc14 { background-color: #808080; }\n"
			header << "\t\t.bc15 { background-color: #C0C0C0; }\n"
			header << "\t</style>\n"
			header << "</head>\n"
			header << "<body>\n"
			f.write(header)
		end
	end

	def add_log(str, raw = false)
		if raw
			super(str)
		else
			super(Time.new.strftime("[%H:%M] ") + str + '<br />')
		end
	end

	def log_msg(user, msg)
		add_log("<b>&lt;#{user}&gt;</b> <span class='m'>#{parse_for_html(msg)}</span>")
	end

	def log_join(user)
		if user == $bot.nick
			add_log("<hr />", true)
		else
			add_log("<span class='j'>*** #{user} has joined ##{@channel}</span>")
		end
	end

	def log_part(user, msg = "")
		add_log("<span class='q'>*** #{user} has left ##{@channel} (#{parse_for_html(msg)})</span>")
	end

	def log_quit(user, msg = "")
		add_log("<span class='q'>*** #{user} has quit IRC (#{parse_for_html(msg)})</span>")
	end

	def log_nick(user, new_nick)
		add_log("<span class='n'>* #{user} is now know as #{new_nick}</span>")
	end

	def log_action(user, action)
		add_log("<span class='a'>* #{user} #{parse_for_html(action)}</span>")
	end

	def log_mode(user, mode, user2)
		add_log("<span class='o'>* #{user} sets mode #{mode} to #{user2}</span>")
	end

	def parse_for_html(str)
		str_temp = ''
		bold_open = false
		color_open = false
		color_opening = false
		back_color_opening = false
		color = ''
		back_color = ''
		color_last = ''
		back_color_last = ''

		begin
			str = str.unpack("U*").pack("C*")
		rescue
		end
  
		str.scan(/./m).each do |c|
			if color_opening
				if back_color_opening
					if c[/\d/] && back_color.size < 2
						back_color += c
						next
					else
						if color_open
							str_temp += '</span>'
						end
						
						color_opening = false
						back_color_opening = false
						
						if back_color.size > 0
							color_open = true
							back_color_last = back_color
							if color.size > 0
								color_last = color
								str_temp += "<span class='c#{color} bc#{back_color}'>"
							elsif color_last.size > 0
								str_temp += "<span class='c#{color_last} bc#{back_color}'>"
							else
								str_temp += "<span class='bc#{back_color}'>"
							end
						elsif color.size > 0
							color_open = true
							color_last = color
							if back_color_last.size > 0
								str_temp += "<span class='c#{color} bc#{back_color_last}'>,"
							else
								str_temp += "<span class='c#{color}'>,"
							end
						else
							color_open = false
							color_last = ''
							back_color_last = ''
							str_temp += ','
						end
					end
				else
					if c[/\d/] && color.size < 2
						color += c
						next
					elsif c == ',' && color.size < 3
						back_color_opening = true
						next
					else
						if color_open
							str_temp += '</span>'
						end
						color_opening = false
						if color.size > 0
							color_open = true
							color_last = color
							if back_color_last.size > 0
								str_temp += "<span class='c#{color} bc#{back_color_last}'>"
							else
								str_temp += "<span class='c#{color}'>"
							end
						else
							color_open = false
							color_last = ''
							back_color_last = ''							
						end
					end
				end
			end

			case c
			when /</
				str_temp += '&lt;'
			when />/
				str_temp += '&gt;'
			when /\002/
				if bold_open
					bold_open = false
					str_temp += '</b>'
				else
					bold_open = true
					str_temp += '<b>'
				end
			when /\003/
				color_opening = true
				back_color_opening = false
				color = ''
				back_color = ''
			when /\017/
				color_last = ''
				back_color_last = ''
				if bold_open
					bold_open = false
					str_temp += '</b>'
				end
				if color_open
					color_open = false
					str_temp += '</span>'
				end
			else
				str_temp += c
			end
		end
		
		str_temp += '</b>' if bold_open
		str_temp += '</span>' if color_open

		# Url parser
		str_temp.gsub!(/(http:\/\/|https:\/\/|www\.)([a-z0-9%\/.:@;?#!=&()~_+-]+)/i) do |i|
			"<a href=\"#{i}\">#{i}</a>"
		end

		str_temp
	end
end
 