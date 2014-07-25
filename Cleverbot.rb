class CleverBotSession
  def initialize
    @url = URI("http://cleverbot.com/webservicemin")
    @vars = {}
    @vars["start"] = "y"
    @vars["icognoid"] = "wsf"
    @vars["fno"] = "0"
    @vars["sub"] = "Say"
    @vars["islearning"] = "1"
    @vars["cleanslate"] = "false"
  end

  def think(thought)
    @vars["stimulus"] = thought

    formData = parametersToWWWFormURLEncoded(@vars)
    formDataToDigest = formData.slice(9, 20)
    formDataDigest = md5(formDataToDigest)
    @vars["icognocheck"] = formDataDigest

    response = post(@url, @vars)

    responseValues = response.split("\r")

    @vars["sessionid"] = stringAtIndex(responseValues, 1)
    @vars["logurl"] = stringAtIndex(responseValues, 2)
    @vars["vText8"] = stringAtIndex(responseValues, 3)
    @vars["vText7"] = stringAtIndex(responseValues, 4)
    @vars["vText6"] = stringAtIndex(responseValues, 5)
    @vars["vText5"] = stringAtIndex(responseValues, 6)
    @vars["vText4"] = stringAtIndex(responseValues, 7)
    @vars["vText3"] = stringAtIndex(responseValues, 8)
    @vars["vText2"] = stringAtIndex(responseValues, 9)
    @vars["prevref"] = stringAtIndex(responseValues, 10)

    @vars["emotionalhistory"] = stringAtIndex(responseValues, 12)
    @vars["ttsLocMP3"] = stringAtIndex(responseValues, 13)
    @vars["ttsLocTXT"] = stringAtIndex(responseValues, 14)
    @vars["ttsLocTXT3"] = stringAtIndex(responseValues, 15)
    @vars["ttsText"] = stringAtIndex(responseValues, 16)
    @vars["lineRef"] = stringAtIndex(responseValues, 17)
    @vars["lineURL"] = stringAtIndex(responseValues, 18)
    @vars["linePOST"] = stringAtIndex(responseValues, 19)
    @vars["lineChoices"] = stringAtIndex(responseValues, 20)
    @vars["lineChoicesAbbrev"] = stringAtIndex(responseValues, 21)
    @vars["typingData"] = stringAtIndex(responseValues, 22)
    @vars["divert"] = stringAtIndex(responseValues, 23)

    stringAtIndex(responseValues, 16)
  end
  
  def urlEncode(txt)
    URI.escape(txt, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  end
  
  def parametersToWWWFormURLEncoded(parameters)
    wwwFormUrlEncoded = nil
    parameters.each_pair do |parameterKey, parameterValue|
      parameter = "#{urlEncode(parameterKey)}=#{urlEncode(parameterValue)}"
      if wwwFormUrlEncoded.nil?
        wwwFormUrlEncoded = parameter;
      else
        wwwFormUrlEncoded = "#{wwwFormUrlEncoded}&#{parameter}"
      end
    end
    wwwFormUrlEncoded
  end

  def md5(input)
    Digest::MD5.hexdigest(input)
  end

  def post(uri, parameters)
    postData = parametersToWWWFormURLEncoded(parameters)

    req = Net::HTTP::Post.new(uri.path)
    req.body = postData
    
    response = Net::HTTP.new(uri.hostname, uri.port).start do |http|
      http.request(req)
    end
    
    response.message.trim
  end

  def stringAtIndex(strings, index)
    strings[index] ? strings[index] : ""
  end
end