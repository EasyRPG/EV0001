# = RealRand
#
# Author::    Maik Schmidt <contact@maik-schmidt.de>
# Copyright:: Copyright (c) 2003 Maik Schmidt
# License::   Distributes under the same terms as Ruby.
#

module Rand
  class OnlineGenerator
    attr_reader :host
    attr_accessor :proxy_host, :proxy_port, :proxy_usr, :proxy_pwd

    def initialize(host)
      @host = host
      @proxy_host = nil
      @proxy_port = -1
      @proxy_usr = nil
      @proxy_pwd = nil
    end

    protected 

    def get_response(script, parameters)
      Net::HTTP::Proxy(
        @proxy_host,
        @proxy_port,
        @proxy_usr,
        @proxy_pwd
      ).start(@host) { |h|
        response = h.get("#{script}?#{parameters}")
        if response.class == Net::HTTPOK
          return response
        else
          raise "An HTTP error occured."
        end
      }
    end
  end
  
  class RandomOrg < OnlineGenerator
    def initialize
      super("www.random.org")
    end

    def randnum(num = 100, min = 1, max = 100)
      if num < 0 || num > 10_000
        raise RangeError, "Invalid amount: #{num}."
      end
      return [] if num == 0
      if min < -1_000_000_000
        raise RangeError, "Invalid minimum: #{min}."
      end
      if max > 1_000_000_000
        raise RangeError, "Invalid maximum: #{max}."
      end
      if max <= min
        raise RangeError, "Maximum has to be bigger than minimum."
      end

      parameters = "num=#{num}&min=#{min}&max=#{max}&col=#{num}"
      response = get_response("/cgi-bin/randnum", parameters)
      convert_result(response.body)
    end

    def randbyte(nbytes = 256)
      if nbytes < 0 || nbytes > 16_384
        raise RangeError, "Invalid amount: #{nbytes}."
      end
      return [] if nbytes == 0
      parameters = "nbytes=#{nbytes}&format=d"
      response = get_response("/cgi-bin/randbyte", parameters)
      convert_result(response.body)
    end

    private

    def convert_result(response)
      result = []
      response.each_line { |line|
        result += line.chomp.split.map { |x| x.to_i }
      }
      result
    end
  end
end

# vim:sw=2

