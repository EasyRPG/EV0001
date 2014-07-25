# EV0001 Bot - Copyright 2011 vgvgf

class Services
	def get_url_info(url)
		
	end
	
	def translate(msg, src = nil, dst = nil)
		Net::HTTP.get_response("example.com","/?search=thing&format=json")
		
	end
  
  def cleverbot(msg)
    @cleverbot.think(msg)
  end
end
