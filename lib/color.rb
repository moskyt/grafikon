module Grafikon
  class Color
    
    MAP = {
      :red => [255, 0, 0],
      :green => [255, 0, 0],
      :blue => [255, 0, 0],
    }
    
    def self.rgb(r, g, b)
      c = new
      c.set_rgb(r, g, b)
    end
    
    def self.name(color_name)
      c = new
      c.set_rgb(*MAP[color_name.to_sym])
    end
    
    def self.ord(i)
      k = MAP.keys
      name(k[i % k.size])
    end
    
    def as_pgfplots
    end
    
  end
end