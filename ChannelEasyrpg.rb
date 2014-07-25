# EV0001 Bot - Copyright 2011 vgvgf

class ChannelEasyrpg < Channel

	def initialize(channel)
		super(channel)
		@commands["web"] = Proc.new { |args| self.say("https://easy-rpg.org/") }
		@commands["blog"] = Proc.new { |args| self.say("https://easy-rpg.org/blog/") }
		@commands["forums"] = Proc.new { |args| self.say("https://easy-rpg.org/forums/") }
		@commands["wiki"] = Proc.new { |args| self.say("https://easy-rpg.org/wiki/") }
		@commands["jenkins"] = Proc.new { |args| self.say("https://easy-rpg.org/jenkins/") }
		@commands["twitter"] = Proc.new { |args| self.say("https://twitter.com/easyrpg/") }
		@commands["identica"] = Proc.new { |args| self.say("https://identi.ca/easyrpg/") }
		@commands["bugs"] = Proc.new { |args| self.say("https://github.com/EasyRPG/Editor/issues https://github.com/EasyRPG/Player/issues https://github.com/EasyRPG/Readers/issues https://github.com/EasyRPG/TestGame/issues") }
		@commands["paste"] = Proc.new { |args| self.say("https://gist.github.com/ (please sign in before pasting if the content is relevant)") }
	end
end
