# EV0001 Bot - Copyright 2011 vgvgf

class UsersStats
	class UserStats
		attr_accessor(:last_seen, :last_msg, :nick, :points, :next_points, :next_points_karma)

		def initialize()
			@last_msg = ""
			@last_seen = Time.now
			@nick = ""
			@points = nil
			@next_points = Time.now
			@next_points_karma = Time.now
		end
	end

	attr_accessor(:users, :current_users)

	def initialize()
		@users = {}
		@current_users = []
		@who_users = []
		
		self.initialize_points
	end
	
	def initialize_points()
		@points_0 = ["pierde el tiempo en {lugar}.",
				"no logra encontrar nada.",
				"no sale de aventuras porque estaba lloviendo.",
				"obtuvo la gran suma de 0 de oro.",
				"durmio durante todo el dia.",
				"estaba demasiado cansado para salir de su casa en {lugar}."]
				
		@points_plus = ["apuesta en el casino y gana {points} de oro.",
			"encuentra un cofre con {points} de oro.",
      "saquea un templo antiguo y obtiene {points} de oro.",
			"despelleja a {monster} mientras investigaba {lugar} y obtiene {points} de oro.",
      "mata a {monster} en {lugar} y obtiene {points} de oro.",
      "destruye a {monster} y obtiene {points} de oro.",
      "derrota a {monster} y obtiene {points} de oro.",
      "vence a {monster} y obtiene {points} de oro.",
      "logra abatir a la gran amenaza de {monster} que estaba en {lugar} y obtiene {points} de oro.",
      "triunfa ante {monster} y obtiene {points} de oro.",
			"encuentra {points} de oro en {lugar}.",
			"cobra {points} de oro por sus trabajos de mercenario.",
			"obtiene {points} de oro por haber terminado con la amenaza de {monster}.",
			"roba {points} de oro a un mendigo.",
      "hurta {points} de oro de una casa.",
      "recibe {points} de oro luego de que sus inversiones en la bolsa dieran fruto.",
			"gana {points} de oro por sus servicios.",
			"vende las joyas familiares y obtiene {points} de oro.",
			"hace un trabajo para la mafia de {lugar} y le pagan {points} de oro.",
			"encuentra {points} de oro en una prenda que hace mucho que no usaba.",
			"+{points} de oro.",
			"asdfg +{points} de oro."]
			
		@points_minus = ["es asaltado por bandidos en {lugar} y se llevan {points} de oro.",
				"se emborracha y despierta con {points} menos de oro.",
				"apuesta en el casino y pierde {points} de oro.",
				"es derrotado en un duelo de insultos y pierde {points} de oro.",
				"compra un artefacto magico que resulto ser falso por {points} de oro.",
				"pierde {points} de oro.",
				"se olvida {points} de oro en {lugar}.",
				"es multado por la caza de {monster} por {points} de oro.",
				"es derrotado por {monster} y termina perdiendo {points} de oro.",
        "es robado por un ladron que se lleva {points} de oro.",
        "vence a {monster} y al volver a su hogar se encuentra que le hurtaron {points} de oro.",
        "es abatido por {monster} y es hopitalizado con un costo de {points} de oro.",
        "malgasta {points} de oro.",
        "desperdicia {points} de oro.",
        "debe pagar {points} de oro por peaje en {lugar}.",
        "extravia {points} de oro en {lugar}.",
        "descansa en una posada por {points}.",
        "debe pagar {points} de oro por peaje en {lugar}.",
        "debe pagar {points} de oro por impuestos.",
        "invierte {points} de oro en una oportunidad que fracasa.",
        "es estafado y pierde {points} de oro.",
				"qwerty -{points} de oro."]

		@points_lugares = ["el bosque", "el bosque oscuro", "un pueblo", "la ciudad", "el desierto","debajo del mar","una cueva fea", "una cueva muy fea","la torre de la oscuridad oscura", "Midgard","el volcan","la meseta de los 4 vientos","unas ruinas","un castillo","la fortaleza de hielo","las minas nordicas"]
		@points_monster = ["un limo verde", "limo verde x 2", "un minotauro", "un lindo gatito", "una vaca furiosa","el chupacabras","bandidos","varios zombies","un mago","hormiga gigante","ratas","serpiente mutante x 2","murcielago x2, limo verde x2","limo azul","limo ninja asesino","ninjas","demonio","nigromante","un jefe de nivel","un oso", "un dragon", "un tiburon zombie","el pollo diablo","MISSINGNO","un jefe barbaro","mothman","una arpia","un vampiro","un hombre lobo","un deathclaw","una rata gigante lvl 102","un ente de agua","un triton","un ente de viento","un ente de fuego","un ente de tierra","un ente electrico","un ente de oscuridad","un ente de luz","un angel","ladron de golosinas"]
		
		@points_challenges_msg = ["humilla a", "derrota a", "destroza a","gana por 2 de HP a","hace perder a","gana a","obtiene la victoria ante","derrota con un golpe bajo a","logra abatir a","triunfa ante","noquea a"]
		
		@points_challenges = []
	end
	
	def include?(nick)
		@current_users.include?(nick.downcase)
	end

	def join(nick)
		create_user(nick)
		@current_users << nick.downcase if !@current_users.include?(nick.downcase)
	end

	def msg(nick, msg)
		create_user(nick)
		@users[nick.downcase].last_seen = Time.now
		@users[nick.downcase].last_msg = "MSG: #{msg}"
		@users[nick.downcase].nick = nick
	end

	def action(nick, msg)
		create_user(nick)
		@users[nick.downcase].last_seen = Time.now
		@users[nick.downcase].last_msg = "ACTION: #{msg}"
		@users[nick.downcase].nick = nick
	end
	
	def quit(nick, msg)
		create_user(nick)
		#@users[nick].last_seen = Time.new
		#@users[nick].last_msg = "QUIT: #{msg}"
		@users[nick.downcase].nick = nick
		@current_users.delete(nick.downcase)
		@points_challenges.delete_if {|i| i[0] == nick.downcase || i[1] == nick.downcase} if !@points_challenges.nil?
	end

	def part(nick, msg)
		create_user(nick)
		#@users[nick].last_seen = Time.new
		#@users[nick].last_msg = "PART: #{msg}"
		@users[nick.downcase].nick = nick
		@current_users.delete(nick.downcase)
		@points_challenges.delete_if {|i| i[0] == nick.downcase || i[1] == nick.downcase} if !@points_challenges.nil?
	end

	def seen(nick)
		nick = nick.downcase
		if @users.has_key?(nick)
			"User #{@users[nick].nick} last seen on #{@users[nick].last_seen.strftime('%Y-%m-%d %H:%M')} - #{@users[nick].last_msg}"
		else
			similar = @users.keys.keep_if {|k| k.include?(nick)}
			if similar.empty?
				"User not seen."
			elsif similar.size == 2
				"User not seen. Looking for " + similar[0] + " or " + similar[1] + "?"
			elsif similar.size > 2
				"User not seen. Looking for " + similar[0, [similar.size, 10].min - 2].join(", ") + " or " + similar[[similar.size, 10].min - 1] + "?"
			else
				"User not seen. Looking for #{similar}?"
			end
		end
	end
	
	def create_user(nick)
		if !@users.has_key?(nick.downcase)
			@users[nick.downcase] = UserStats.new
			@users[nick.downcase].nick = nick
		end
		@users[nick.downcase]
	end
	
	def start_who()
		@who_users = []
	end
	
	def add_who(nick)
		@users[nick.downcase] = UserStats.new() if !@users.has_key?(nick.downcase)
		@users[nick.downcase].nick = nick
		@who_users << nick.downcase if !@who_users.include?(nick.downcase)
	end
	
	def end_who()
		@points_challenges.delete_if {|i| @who_users.include?(i[0]) || @who_users.include?(i[1]) } if !@points_challenges.nil?
		@current_users.delete_if do |user|
			!@who_users.include?(user)
		end
	end
	
	def get_points(nick)
		user = create_user(nick)
		user.points = 5 if user.points.nil?
    sorted = @users.select {|k, v| !v.points.nil?}.values.sort {|x, y| y.points <=> x.points}
		nick + " tiene " + user.points.to_s + " de oro. Se encuentra en el puesto #{sorted.index {|i| i == user}}"
	end
	
	def get_points_top()
		sorted = @users.select {|k, v| !v.points.nil?}.values.sort {|x, y| y.points <=> x.points}
		if sorted.size >= 4
			"Primero #{sorted[0].nick} con #{sorted[0].points} de oro - Segundo #{sorted[1].nick} con #{sorted[1].points} de oro - Tercero #{sorted[2].nick} con #{sorted[2].points} de oro - Ultimo #{sorted[sorted.size-1].nick} miserablemente con #{sorted[sorted.size-1].points} de oro." 
		else
			"Se necesitan mas usuarios en el juego."
		end
	end
	
	def points_plus(nick, target)
		user = create_user(nick)
		user.points = 5 if user.points.nil?
		
		if nick.downcase == target.downcase
      return "#{nick} intenta darse oro a el mismo. Nice try..."
    elsif target.downcase == $bot.nick.downcase
      
		elsif !@users.include?(target.downcase)
			return "El usuario #{target} no existe"
		elsif !@current_users.include?(target.downcase)
			return "El usuario #{target} debe estar conectado."
		elsif @users[target.downcase].points.nil?
			return "El usuario #{target} no ha entrado en el juego."		
		end
	
		user.next_points_karma = Time.now if user.next_points_karma.nil?
		if user.next_points_karma <= Time.now
			user.next_points_karma = Time.now + 86400
      if target.downcase == $bot.nick.downcase
        $bot.nick + " agradece a " + nick + " por su contribucion."
      else
  			@users[target.downcase].points += 2
    		@users[target.downcase].nick + " obtiene 2 de oro gracias a " + nick
      end
		else
			"#{nick} no puede socializar tan rapido."
		end
	end
	
	def points_minus(nick, target)
		user = create_user(nick)
		user.points = 5 if user.points.nil?
		
    if nick.downcase == target.downcase
      return "#{nick} intenta quitarse oro a el mismo. Deberia tener verguenza."
    elsif target.downcase == $bot.nick.downcase
		elsif !@users.include?(target.downcase)
			return "El usuario #{target} no existe"
		elsif !@current_users.include?(target.downcase)
			return "El usuario #{target} debe estar conectado."
		elsif @users[target.downcase].points.nil?
			return "El usuario #{target} no ha entrado en el juego."		
		end
		
		user.next_points_karma = Time.now if user.next_points_karma.nil?
		if user.next_points_karma <= Time.now
			user.next_points_karma = Time.now + 86400
      if target.downcase == $bot.nick.downcase
        user.points = [user.points - 1, 0].max
        nick + " pierde 1 de oro culpa de " + $bot.nick
      else
        @users[target.downcase].points = [@users[target.downcase].points - 1, 0].max
        @users[target.downcase].nick + " pierde 1 de oro culpa de " + nick
      end
		else
			"#{nick} no puede socializar tan rapido."
		end
	end
	
	def challenge(nick, target)
		user = create_user(nick)
		user.points = 5 if user.points.nil?
    
    if nick.downcase == target.downcase
      return "#{nick} intenta retar a el mismo a un duelo. Deberia tener verguenza."
    elsif target.downcase == $bot.nick.downcase
       nil
    elsif !@users.include?(target.downcase)
			return "El usuario #{target} no existe"
		elsif !@current_users.include?(target.downcase)
			return "El usuario #{target} debe estar conectado."
		elsif @users[target.downcase].points.nil?
			return "El usuario #{target} no ha entrado en el juego."
		elsif @users[target.downcase].next_points >= Time.now
			#return "El usuario #{target} esta demasiado cansado para participar en un duelo."
		end
		
		#if user.next_points <= Time.now
      if target.downcase == $bot.nick.downcase
        points = 3 + Rand.rand(7)
        points = user.points if user.points - points < 0
				user.points -= points
        msg = @points_challenges_msg.sample
        return $bot.nick + " " + msg + " " + user.nick + " y le quita #{points} de oro."
      end
      
			challenged = @points_challenges.select {|i| i[0] == target.downcase && i[1] == nick.downcase}
			if !challenged.nil? && challenged[0]
				winner = Rand.rand(2) == 0
				msg = @points_challenges_msg.sample
				points = 3 + Rand.rand(7)
				
        @points_challenges.delete_if {|i| i[0] == nick.downcase || i[1] == nick.downcase}
				@points_challenges.delete_if {|i| i[0] == target.downcase || i[1] == target.downcase}
        user.next_points = Time.now + 86400
        @users[target.downcase].next_points = Time.now + 86400
        
				if winner
          points = @users[target.downcase].points if @users[target.downcase].points - points < 0
					user.points += points
					@users[target.downcase].points -= points
					return user.nick + " " + msg + " " + @users[target.downcase].nick + " y le quita #{points} de oro."
				else
          points = user.points if user.points - points < 0
					user.points -= points
					@users[target.downcase].points += points
					return @users[target.downcase].nick + " " + msg + " " + user.nick + " y le quita #{points} de oro."
				end
			end
			
			challenges = @points_challenges.select {|i| i[0] == target.downcase && i[1] == nick.downcase}
			if !challenges.nil? && challenges[0]
				"Ya se ha retado a #{target} a un duelo. #{target} debe responder con :battle_challenge #{nick} para aceptar."
			else
        @points_challenges << [nick.downcase, target.downcase]
				"#{nick} reta a un duelo a #{target}. #{target} debe responder con :battle_challenge #{nick} para aceptar."
			end
		#else
		#	"#{nick} esta demasiado cansado para participar en un duelo."
		#end
	end
	
	def battle_points(nick)
		user = create_user(nick)
		user.points = 5 if user.points.nil?
		user.next_points = Time.now if user.next_points.nil?
		if user.next_points <= Time.now
      @points_challenges.delete_if {|i| i[0] == nick.downcase || i[1] == nick.downcase}

			points = - 4 + Rand.rand(10)
			user.points = [user.points + points, 0].max
			user.next_points = Time.now + 86400
			if points == 0
				self.points_replace_msg(nick, @points_0.sample.clone, points, user.points)
			elsif points < 0
				self.points_replace_msg(nick, @points_minus.sample.clone, points * -1, user.points)
			else
				self.points_replace_msg(nick, @points_plus.sample.clone, points, user.points)
			end
		else
			"#{nick} no puede salir de aventura tan rapido. Cuenta con #{user.points} de oro."
		end
	end
	
	def points_replace_msg(nick, msg, points, user_points)
		msg["{lugar}"] = @points_lugares.sample if msg["{lugar}"]
		msg["{monster}"] = @points_monster.sample if msg["{monster}"]
		msg["{points}"] = points.to_s if msg["{points}"]
		nick + " " + msg + " Ahora cuenta con #{user_points} de oro."
	end
end
