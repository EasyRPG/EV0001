# EV0001 Bot - Copyright 2011 vgvgf

class Bot < BotLog
	attr_accessor(:nick, :channels, :owners)

	def initialize()
		super()

		@owners = OWNERS

		self.setup_user

		@channels = {}
		CHANNELS.each do |c|
			@channels[c.channel] = c
			c.join
		end

		@next_log = Time.now + 60
		@timer_10min = Time.now + 600
		@timer_10_5min = nil
	end

	def setup_user
		nick_id = 0
		loop do
			$irc.nick(NICKS[nick_id])
			$irc.user(NICKS[nick_id])
			loop do
				$irc.update
				breakloop = false
				until $irc.empty?
					msg = $irc.poll
					p msg if $DEBUG
					case msg
					when /^:(.+?)\s(.+?)\s(.+)$/i
						case $2
						when '001' # All OK
							@nick = NICKS[nick_id]
							return
						when '433' # Nick in use
							sleep(2)
							nick_id = (nick_id + 1) % NICKS.size
							$irc.user(NICKS[nick_id])
							breakloop = true
							break
						end
					end
				end
				break if breakloop
				sleep(0.2)
			end
		end
		$irc.umode("-i", NICKS[nick_id])
	end

	def quit
		self.do_all_tasks
		
		@channels.each do |k, v|
			v.part
		end
		sleep(1)
		$irc.quit
		sleep(1)
		exit
	end

	def update
		until $irc.empty?
			begin
				self.handle_input($irc.poll)
			rescue
        $last_error = $!
				$bot.log_error("ERROR", $!)
			end
		end
		self.update_timer
	end

	def update_timer
		#if $DEBUG
		#	self.write_all_logs
		#	return
		#end
		time = Time.now
		if time > @next_log
			@next_log = time + 60
			self.write_all_logs
		end
		if time > @timer_10min
			@timer_10min = time + 600
			@timer_10_5min = time + 300
			self.save_all_users
		end
		if @timer_10_5min && time > @timer_10_5min
			@timer_10_5min = nil
			@channels.each do |k, v|
				v.update_users
			end
		end
	end

	def do_all_tasks
		self.write_all_logs
		self.save_all_users
	end

	def save_all_users
		@channels.each do |k, v|
			v.save_users
		end
	end

	def write_all_logs
		@channels.each do |k, v|
			v.write_log
		end
		self.write_log
	end

	def handle_input(msg)

		p msg if $DEBUG
		
		case msg.strip
		when /^ERROR :(.+)$/i
			self.add_log("IRC ERROR: #{$1}")
			self.write_all_logs
			exit

		when /^PING :(.+)$/i
			$irc.send Irc::Message.new("PONG :#{$1}", 5)

		when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s.+\s:[\001]PING (.+)[\001]$/i
			$irc.send Irc::Message.new("NOTICE #{$1} :\001PING #{$4}\001", 5)

		when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s.+\s:[\001]VERSION[\001]$/i
			$irc.send Irc::Message.new("NOTICE #{$1} :\001VERSION #{@nick} from MAP0001 at (028,087)\001", 5)

		when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s#{@nick}\s:(.+)$/i
			self.handle_msg_cmds("#{$1}!#{$2}@#{$3}", $1, $4)

		when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s#(.+?)\s:[\001]ACTION\s(.+)[\001]$/i
			@channels[$4].log_action($1, $5)

		when /^:(.+?)!(.+?)@(.+?)\sPRIVMSG\s#(.+?)\s:(.+)$/i
			@channels[$4].log_msg($1, $5)

			@channels[$4].handle_msg_cmds("#{$1}!#{$2}@#{$3}", $1, $5)

		when /^:(.+?)!(.+?)@(.+?)\sMODE\s#(.+)\s(.+)\s(.+)$/i
			@channels[$4].log_mode($1, $5, $6)

		when /^:(.+?)!(.+?)@(.+?)\sPART\s#(.+?)\s:(.+)$/i
			@channels[$4].log_part($1, $5)

		when /^:(.+?)!(.+?)@(.+?)\sPART\s#(.+?)$/i
			@channels[$4].log_part($1)
			
		when /^:(.+?)!(.+?)@(.+?)\sPART\s#(.+?).*?$/i
			@channels[$4].log_part($1)

		when /^:(.+?)!(.+?)@(.+?)\sJOIN\s:#(.+)$/i
		when /^:(.+?)!(.+?)@(.+?)\sJOIN\s#(.+)$/i
			@channels[$4].log_join($1)

		when /^:(.+?)!(.+?)@(.+?)\sQUIT\s:(.+?)$/i
			@channels.each do |k, v|
				v.log_quit($1, $4)
			end

		when /^:(.+?)!(.+?)@(.+?)\sQUIT.*?$/i
			@channels.each do |k, v|
				v.log_quit($1)
			end

		when /^:(.+?)!(.+?)@(.+?)\sNICK\s:(.+)$/i
			@channels.each do |k, v|
				v.log_nick($1, $4)
			end
		when /^:.+?\.freenode\.net\s353\s#{@nick}\s[@=*]\s#(.+?)\s:(.+)$/i
			@channels[$1].list_users($2)

		when /^:.+?\.freenode\.net\s366\s#{@nick}\s#(.+?)\s:.+$/i
			@channels[$1].end_list_users()
			
		when /^:.+?\.freenode\.net\s352\s#{@nick}\s#(.+?)\s(.+)$/i
			@channels[$1].who_users($2)

		when /^:.+?\.freenode\.net\s315\s#{@nick}\s#(.+?)\s:.+$/i
			@channels[$1].end_who_users()
			
		when /^:.+?\.freenode\.net\s376\s#{@nick}\s:.+$/i
			$irc.privmsg("NickServ",  "identify " + PASS)
		end
	end

	def handle_msg_cmds(sender, user, msg)
		case msg
		when /^:EVAL(N)? (.+)$/i
			accept = @owners.include?(sender)
			self.add_log("EVAL #{$2} from #{sender} - #{accept ? 'OK' : 'Denied'}")
			if accept
				begin
					result = eval($2).to_s
					$irc.notice(user, result.slice(0, 512)) if $1 != "N"
				rescue
          $last_error = $!
					self.log_error('EVAL', $!)
					$irc.notice(user, ("ERROR: #{$!}").slice(0, 512))
				end
			else
				$irc.notice(user, "Access Denied.")
			end
		end
	end
end
