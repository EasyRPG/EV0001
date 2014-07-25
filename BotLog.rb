# EV0001 Bot - Copyright 2011 vgvgf

class BotLog < Log
	def initialize
		super('')
		@file = 'botlog.txt'
	end

	def add_log(str, time = true)
		if time
			super(Time.new.strftime("[%Y-%m-%d %H:%M] ") + str)
		else
			super(str)
		end
	end

	def log_error(type, error)
		self.add_log("#{type} ERROR: #{error}") rescue nil
		self.add_log("\t\t#{error.backtrace[0]}", false) rescue nil
		self.add_log("\t\t#{error.backtrace[1]}", false) rescue nil
	end
end
