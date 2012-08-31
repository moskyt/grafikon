module Grafikon
  class Color
    
    MAP = {
      :red => [255, 0, 0],
      :green => [0, 255, 0],
      :blue => [0, 0, 255],
      :orange => [255, 200, 0],
      :magenta => [255, 0, 255],
      :lightblue => [150, 150, 250],
      :darkblue => [0, 0, 100],
      :gray => [120, 120, 120],
    }
    
    def self.rgb(r, g, b)
      c = new
      c.set_rgb(r, g, b)
      c
    end
    
    def self.name(color_name)
      c = new
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