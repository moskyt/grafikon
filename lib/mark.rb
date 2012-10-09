module Grafikon
  class Mark
    #\usetikzlibrary{plotmarks}
    SET = [
      :circle_filled, :Circle,
      :dcross, :x,
      :cross, :plus,
      :none
      ]
    LIST = [
      :Circle,
      :dcross,
      :cross
      ]  
          
    def initialize(kind)
      SET.include?(kind) or raise ArgumentError, "Unknown mark type [#{kind}]"
      @kind = kind
    end  
    
    def self.ord(n)
      new(LIST[n % LIST.size])
    end
    
    def as_pgfplots
      case @kind 
      when :circle_filled, :Circle
        '*'
      when :dcross, :x
        'x'
      when :cross, :plus
        '+'
      when :none
        'none'
      else
        raise ArgumentError, "Marker kind mismatch /#{@kind}/"
      end
    end
  end
end