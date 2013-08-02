module Grafikon
  class Mark
    #\usetikzlibrary{plotmarks}
    SET = [
      :Circle, :circle_filled, 
      :dcross, :x,
      :cross, :plus,
      :vertical,
      :horizontal,
      :circle, :o,
      :circle_cross,
      :circle_dcross,
      :square,
      :Square,
      :triangle,
      :Triangle, :triangle_filled,
      :diamond,
      :Diamond, :diamond_filled,
      :pentagon,
      :Pentagon, :pentagon_filled,
      :asterisk,
      :star,
      :none,
      ]
    LIST = [
      :Circle,
      :dcross,
      :cross,
      :vertical,
      :horizontal,
      :circle,
      :circle_cross,
      :circle_dcross,
      :square,
      :Square,
      :triangle,
      :Triangle,
      :diamond,
      :Diamond,
      :pentagon,
      :Pentagon,
      :asterisk,
      :star,
      ]  
          
    def initialize(kind)
      SET.include?(kind) or raise ArgumentError, "Unknown mark type [#{kind}]"
      @kind = kind
    end  
    
    def self.ord(n)
      new(LIST[n % LIST.size])
    end
    
    def none?
      @kind == :none
    end
    
    def as_gnuplot
      case @kind
      when :none
        -1
      when :cross, :plus
        1
      when :dcross, :x
        2
      when :asterisk, :star
        3
      when :circle
        6
      when :Circle, :circle_filled
        7
      when :triangle 
        8
      when :Triangle, :triangle_filled
        9
      when :pentagon
        14
      when :Pentagon, :pentagon_filled
        15
      when :square
        4
      when :Square, :square_filled
        5
      when :diamond
        12
      when :Diamond, :diamond_filled
        13
      else
        7
      end
    end
    
    def as_pgfplots
      case @kind 
      when :circle_filled, :Circle
        '*'
      when :dcross, :x
        'x'
      when :cross, :plus
        '+'
      when :vertical
        '|'
      when :horizontal
        '-'
      when :circle, :o
        'o'
      when :circle_cross
        'oplus'
      when :circle_dcross
        'otimes'
      when :square
        'square'
      when :Square
        'square*'
      when :diamond
        'diamond'
      when :Diamond, :diamond_filled
        'diamond*'
      when :pentagon
        'pentagon'
      when :Pentagon, :pentagon_filled
        'pentagon*'
      when :triangle
        'triangle'
      when :Triangle, :triangle_filled
        'triangle*'
      when :none
        'none'
      when :asterisk
        'asterisk'
      when :star
        'star'
      else
        #raise ArgumentError, "Marker kind mismatch /#{@kind}/"
        '*'
      end
    end
  end
end