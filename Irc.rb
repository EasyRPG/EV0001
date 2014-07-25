# EV0001 Bot - Copyright 2011 vgvgf

class Irc
	class Message
		attr_accessor(:msg, :flood, :delay, :log)
		
		def initialize(msg, flood, delay = nil, log = nil)
			@msg = msg
			@flood = flood
			@delay = delay
			@log = log
		end
	end
	
	attr_accessor(:ready, :socket, :thread)

	def initialize(server, port)
		@ready = false
		@socket = TCPSocket.open(server, port)
		@send_queue = []
		@last_send = Time.now
		@flood_time = Time.now
		@bytes_flood = 0
		@bytes_penalty = 0
		@msg_flood = 0
		@msg_penalty = 0
		@in_queue = []
		@delayed_msg = []
	end

	def gets
		return @in_queue << @socket.gets

		str = @socket.gets

		begin
			str = str.unpack("U*").pack("C*")
		rescue
		end

		@in_queue << str
	end
	
	def enqueue(msg, flood = 5)
		if msg.size > MAX_MSG_BYTES
			$bot.add_log('DROPPED MSG: ' + msg)
			return
		end
		
		@send_queue << Message.new(msg, flood)
	end

	def send(msg)
		p "SEND: " + msg.msg if $DEBUG
		@bytes_flood += msg.msg.size + 1
		if @bytes_flood > BYTES_PER_SEC_PENALTY
			@bytes_penalty = BYTES_PER_SEC_PENALTY - @bytes_flood
		end
		@msg_flood += msg.flood
		if @msg_flood >= 100
			@msg_penalty = 20
		end
		@socket.puts(msg.msg)
	end

	def update
		time_diff = Time.now - @flood_time
		
		if @bytes_penalty > 0
			@bytes_penalty = [@bytes_penalty - (MAX_BYTES_PER_SEC / 2.0) * time_diff, 0].max
		elsif @bytes_flood > 0
			@bytes_flood = [@bytes_flood - (MAX_BYTES_PER_SEC) * time_diff, 0].max
		end
		
		if @msg_penalty > 0
			@msg_penalty = [@msg_penalty - 20 * time_diff, 0].max
		elsif @msg_flood > 0
			@msg_flood = [@msg_flood - 50 * time_diff, 0].max
		end
		
		@flood_time = Time.now
		
		if !@delayed_msg.empty?
			msgs = @delayed_msg.select {|m| m.delay <= @flood_time}
			if !msgs.nil?
				@send_queue.concat(msgs)
				msgs.each do |m|
					m.log.call
				end
			end
			@delayed_msg.delete_if {|m| m.delay <= @flood_time}
		end		
		
		loop do
			break if @send_queue.empty? || @bytes_penalty > 0 || @msg_penalty > 0
			break if @bytes_flood + @send_queue[0].msg.size > MAX_BYTES_PER_SEC
			self.send(@send_queue.slice!(0))
		end
	end

	def empty?
		@in_queue.empty?
	end

	def poll
		@in_queue.slice!(0)
	end

	def nick(nick)
		self.enqueue "NICK #{nick}"
	end

	def user(user1, user2 = user1)
		self.enqueue "USER #{user1} 0 * #{user2}"
	end

	def privmsg(user, msg)
		while msg.length > 0
			self.enqueue crop_msg("PRIVMSG #{user} :", msg), 15
		end
	end

	def msg(channel, msg)
		while msg.length > 0
			self.enqueue crop_msg("PRIVMSG ##{channel} :", msg), 15
		end
	end
	
	def delayed_msg(channel, msg, time, log)
		while msg.length > 0
			@delayed_msg << Message.new(crop_msg("PRIVMSG ##{channel} :", msg), 15, time, log)
		end
		@delayed_msg.sort! {|x,y| x.delay <=> y.delay }
	end

	def join(channel)
		self.enqueue "JOIN ##{channel}"
	end

	def notice(user, msg)
		while msg.length > 0
			self.enqueue crop_msg("NOTICE #{user} :", msg), 15
		end
	end

	def names(channel)
		self.enqueue "NAMES ##{channel}"
	end
	
	def who(channel)
		self.enqueue "WHO ##{channel}"
	end

	def part(channel, msg = nil)
		if msg
			self.enqueue crop_msg("PART ##{channel} :", msg)
		else
			self.enqueue "PART ##{channel}"
		end
	end

	def quit(msg = nil)
		if msg
			self.enqueue "QUIT :#{msg}"
		else
			self.enqueue "QUIT"
		end
	end

	def kick(channel, user, reason = nil)
		if reason
			self.enqueue crop_msg("KICK ##{channel} #{user} :", reason)
		else
			self.enqueue "KICK ##{channel} #{user}"
		end
	end

	def mode(channel, mode, user)
		self.enqueue "MODE ##{channel} #{mode} #{user}"
	end

	def whois(user)
		self.enqueue "WHOIS #{user}"
	end

	def umode(user, mode)
		self.enqueue "MODE #{user} #{mode}"
	end
  
  def crop_msg(str, msg)
    str + msg.slice!(0, [msg.length, MAX_MSG_BYTES - 1 - str.length].min)
  end
end
