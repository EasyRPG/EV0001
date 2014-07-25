# EV0001 Bot - Copyright 2011 vgvgf

class Channel < ChannelLog
	attr_accessor(:connected, :channel)

	def initialize(channel)
		super(channel)
		@channel = channel
		@connected = false
		@block_denied = []
		@commands = {}
		@commands["log"] = Proc.new do |args|
			time = nil
			if args[2].strip.empty?
				time = Time.new
			else
				case args[2]
				when /^(yesterday|ayer)$/
					time = Time.new - 60 * 60 * 24 rescue nil
				when /^-(\d+)$/
					time = Time.new - $1.to_i * 60 * 60 * 24 rescue nil
				when /^[+](\d+)$/
					time = Time.new + $1.to_i * 60 * 60 * 24 rescue nil
				when /^(\d+)$/
					time = Time.utc(Time.new.year, Time.new.month, $1.to_i) rescue nil
				when /^(\d+)-(\d+)$/
					time = Time.utc(Time.new.year, $1.to_i, $2.to_i) rescue nil
				when /^(\d+)-(\d+)-(\d+)$/
					time = Time.utc($1.to_i, $2.to_i, $3.to_i) rescue nil
				end
			end
			if time
				path = "#{@channel}/#{time.strftime('%Y-%m-%d.html')}"
				if File.exists?("#{LOG_PATH}#{path}")
					self.say("#{LOG_URL}#{path}")
				elsif args[2].strip.empty?
					self.write_log
					self.say("#{LOG_URL}#{path}")
				else
					self.say("#{LOG_URL}#{path} does not exist.")
				end
			else
				self.say("Invalid argument.")
			end
		end
		@commands["log-help"] = ":log {days ago|day|month-day|year-month-day|+days after?}"
		@commands["seen"] = Proc.new do |args|
			if args[2].strip.empty?
				self.say("Enter a nick.")
			else
				self.say(@users.seen(args[2].strip))
			end
		end
		@commands["seen-help"] = ":seen {nick}"
		@pizza_timer = Time.now
		@commands["pizza"] = Proc.new do |args|
			if @pizza_timer < Time.now
				@pizza_timer = Time.now + 300
				self.say("           _....._")
				self.say("       _.:`.--|--.`:._")
				self.say("     .: .'\\o  | o /'. '.")
				self.say("    // '.  \\ o|  /  o '.\\")
				self.say("   //'._o'. \\ |o/ o_.-'o\\\\")
				self.say("   || o '-.'.\\|/.-' o   ||")
				self.say("   ||--o--o-->|<o-----o-||")
				self.say("   \\\\  o _.-'/|\\'-._o  o//")
				self.say("    \\\\.-'  o/ |o\\ o '-.//")
				self.say("     '.'.o / o|  \\ o.'.'")
				self.say("       `-:/.__|__o\\:-'")
				self.say("          `\"--=--\"`")				
			else
				self.say("Pizza is still cooking...")
			end
		end
		@commands["pizza-help"] = "#{$bot.nil? ? "EV0001" : $bot.nick} sends a tasty pizza"
		@commands["drink"] = Proc.new do |args|
			self.say("         .:.      .:.         .:.")
			self.say("       _oOoOo   _oOoOo       oOoOo_")
			self.say("      [_|||||  [_|||||       |||||_]")
			self.say("        |||||    |||||       |||||")
			self.say("        ~~~~~    ~~~~~       ~~~~~")			
		end
		@commands["drink-help"] = "#{$bot.nil? ? "EV0001" : $bot.nick} sends some drinks"
		@commands["help"] = Proc.new do |args|
			if args[2].strip.empty?
				cmds = []
				@commands.each do |k, v|
					cmds << k if v.is_a?(Proc)
				end
				self.say("Available commands:" + cmds.join(" "))
			else
				if @commands.has_key?(args[2].strip)
					self.say("#{@commands[args[2].strip + "-help"]}")
				else
					self.say("invalid command. Type :help for available commands.")
				end
			end
		end
		@commands["help-help"] = ":help (command)"

		@users = UsersStats.new()

		begin
			if File.exists?("Data/#{@channel}_users.data")
				File.open("Data/#{@channel}_users.data", 'rb') do |f|
					@users = Marshal.load(f)
				end
			end
		rescue
      $last_error = $!
		end
	end

	def join
		$irc.join(@channel)
	end

	def part(msg = nil)
		$irc.part(@channel, msg)
	end

	def say(msg)
    msg = msg.to_s
		self.log_msg($bot.nick, "#{msg}")
		$irc.msg(@channel, msg.dclone)
	end

	def list_users(msg)
		msg.split(/\s/).each do |user|
			if user[0, 1] == "@" or user[0, 1] == "+"
				@users.join(user[1, user.size - 1])
			else
				@users.join(user)
			end
		end
	end

	def end_list_users()

	end
	
	def who_users(msg)
		if msg[/^.+?\s.+?\s.+?\s(.+?)\s[H|G][*]?[@|+]?\s:\d+\s.+$/i]
			@users.add_who($1)
		end
	end
	
	def end_who_users()
		@users.end_who
	end

	def log_msg(user, msg)
		@users.msg(user, msg)
		super(user, msg)
	end

	def log_join(user)
		if user.downcase != $bot.nick.downcase
			@users.join(user)
		end
		super(user)
	end

	def log_part(user, msg = "")
		@users.part(user, msg)
		super(user, msg)
	end

	def log_quit(user, msg = "")
		if @users.include?(user)
			@users.quit(user, msg)
			super(user, msg)
		end
	end

	def log_nick(user, new_nick)
		if @users.include?(user)
			@users.join(new_nick)
			super(user, new_nick)
		end
	end

	def log_action(user, action)
		@users.action(user, action)
		super(user, action)
	end

	def save_users
		begin
			File.open("Data/#{@channel}_users.data", 'wb') do |f|
				Marshal.dump(@users, f)
			end
		rescue
      $last_error = $!
		end
	end

	def update_users
		@users.start_who
		$irc.who(@channel)
	end

	def handle_msg_cmds(sender, user, msg)
		case msg
		when /^:EVAL(N)? (.+)$/i
			accept = $bot.owners.include?(sender)
			$bot.add_log("[ EVAL #{$2} from #{sender} - #{accept ? 'OK' : 'Denied'}]")
			if accept
				begin
					result = eval($2).to_s
					$irc.notice(user, result.slice(0, 512)) if $1 != "N"
				rescue
          $last_error = $!
					$irc.notice(user, ("ERROR: #{$!}").slice(0, 512))
					$bot.log_error("ERROR", $!)
				end
			else
				$irc.notice(user, "Access Denied.")
			end
		when /^:(.+)\s(.+)$/i
      begin
        if @commands.has_key?($1) && @commands[$1].is_a?(Proc)
  				@commands[$1].call([sender, user, $2])
    		end
       rescue
          $last_error = $!
				 	$irc.notice(user, ("ERROR: #{$!}").slice(0, 512))
					$bot.log_error("ERROR", $!)
				end
		when /^:(.+)$/i
      begin
        if @commands.has_key?($1) && @commands[$1].is_a?(Proc)
          @commands[$1].call([sender, user, ''])
        end
      rescue
          $last_error = $!
					$irc.notice(user, ("ERROR: #{$!}").slice(0, 512))
					$bot.log_error("ERROR", $!)
				end
		end
	end
end
