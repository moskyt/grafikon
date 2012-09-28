module Grafikon
  class Color
    
    attr_reader :r, :g, :b
    
    MAP = {
      :red => [1.0, 0, 0],
      :green => [0, 1.0, 0],
      :blue => [0, 0, 1.0],
      :orange => [1.0, 0.5, 0],
      :yellow => [1.0, 1.0, 0],
      :magenta => [1.0, 0, 1.0],
      :lightblue => [0.5, 0.5, 1.0],
      :darkblue => [0, 0, 0.4],
      :gray => [0.8, 0.8, 0.8],
    }
    
    def self.rgb(r, g, b)
      c = new
      c.set_rgb(r, g, b)
      c
    end
    
    def self.name(color_name)
      c = new
      MAP[color_name.to_sym] or raise ArgumentError, "Color [#{color_name}] not known"
      c.set_rgb(*MAP[color_name.to_sym])
      c
    end
    
    def self.ord(i)
      k = MAP.keys
      name(k[i % k.size])
    end
    
    def set_rgb(r,g,b)
      @r, @g, @b = r, g, b
    end
    
    def as_pgfplots
      "{rgb:red,#{@r};green,#{@g};blue,#{@b}}"
    end
    
  end
end