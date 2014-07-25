# EV0001 Bot - Copyright 2011 vgvgf

class ChannelRpgMakerEs < Channel
	def initialize(channel)
		super(channel)
		
		@commands["battle"] = Proc.new do |args|
			self.say(@users.battle_points(args[1]))
		end
    @commands["battle-help"] = "Cada 24hs puedes usar :battle y asi ganar oro (o a veces perderlo)."
		
		@commands["battle_oro"] = Proc.new do |args|
			self.say(@users.get_points(args[1]))
		end
    @commands["battle_oro-help"] = "Obtiene tu oro actual."
		
		@commands["battle_top"] = Proc.new do |args|
			self.say(@users.get_points_top)
		end
    @commands["battle_top-help"] = "El ranking de oro, al menos 4 usuarios deben haber jugado."
		
		@commands["battle_gift"] = Proc.new do |args|
			self.say(@users.points_plus(args[1], args[2].strip))
		end
    @commands["battle_gift-help"] = ":battle_gift {nick} - Cada 24hs puedes hacer ganar 2 de oro a un usuario."
		
		@commands["battle_attack"] = Proc.new do |args|
			self.say(@users.points_minus(args[1], args[2].strip))
		end
    @commands["battle_attack-help"] = ":battle_attack {nick} - Cada 24hs puedes hacer perder 1 de oro a un usuario."
		
		@commands["battle_challenge"] = Proc.new do |args|
			self.say(@users.challenge(args[1], args[2].strip))
		end
    @commands["battle_challenge-help"] = ":battle_challenge {nick} - Reta a un duelo a otro usuario que debera responder con :battle_challenge {tu_nick}. El ganador se llevara oro del otro."
		
		@commands["hola"] = Proc.new do |args|
			self.say_random_greet(args[2].strip.empty? ? args[1].strip : args[2].strip, Rand.rand(2) == 0)
		end
    @commands["hola-help"] = "hola [nick]"
    		
		greets = [["hola",60],[ "buenas",40], ["hi", 10], ["nas", 30], ["holas", 20], ["hello",10], ["greetings", 3], ["saludos", 10], ["asd",1], ["hallo",5], ["como va?",5], ["como vas?",5], ["sup",5], ["ola",1], ["howdy",5], ["...",3], [":)",4], ["bienvenido a #rpgmaker.es",3],["http://www.youtube.com/watch?v=oHg5SJYRHA0",1],["yo", 9],["wea",9],["andale",4],["andele",4]]
		@greets = []
		greets.each do |i|
			i[1].times do |e|
				@greets << i[0]
			end
		end
	end
	
	def say_random_greet(nick = "", prepend = false)
		greet = @greets[Rand.rand(@greets.size)]
		return if greet.nil?
		
		n = Rand.rand(100)
		if n > 50
			greet[0] = greet[0].upcase
		elsif n == 0
			greet = greet.upcase
		end
		greet = nick + ", " + greet if !nick.empty? && prepend
		greet += " " + nick if !nick.empty? && !prepend
		greet_proc = Proc.new { |args| self.log_msg($bot.nick, "#{greet}")}
		$irc.delayed_msg(@channel, greet.dclone.to_s, Time.now + rand(10), greet_proc)
	end
	
	def log_join(user)
		super(user)
	end
	
	def handle_msg_cmds(sender, user, msg)
    case msg
		when /^(.+?)[,:](.+)$/i
      if $1.downcase == $bot.nick.downcase
        $irc.msg(@channel, ";)")
      end
		end
    
		super(sender, user, msg)
	end
end
