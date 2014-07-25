# EV0001 Bot - Copyright 2011 vgvgf

module Rand
  @cache = []
  @random = RandomOrg.new

  def self.rand(max)
    return Kernel.rand(max)
    if @cache.empty?
      @cache = @random.randnum(100, 0, 10000)
    end
    a = @cache.shift % max
    @a << a
    a
  end
end