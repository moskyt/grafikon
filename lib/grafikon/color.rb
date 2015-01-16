module Grafikon
  # versatile wrapper for color processing
  class Color
    
    # red component
    attr_reader :r
    # green component
    attr_reader :g
    # blue component
    attr_reader :b
    
    # several predefined colors
    MAP = {
      :red => [1.0, 0, 0],
      :blue => [0, 0, 1.0],
      :orange => [1.0, 0.5, 0],
      :darkgreen => [0, 0.3, 0],
      :darkblue => [0, 0, 0.4],
      :magenta => [1.0, 0, 1.0],
      :lightgreen => [0.4, 0.7, 0.4],
      :lightblue => [0.5, 0.5, 1.0],
      :green => [0, 0.7, 0.1],
      :yellow => [0.7, 0.7, 0],
      :gray => [0.8, 0.8, 0.8],
      :black => [0, 0, 0],
    }
     
    # constructor-by-RGB
    def self.rgb(r, g, b)
      c = new
      c.set_rgb(r, g, b)
      c
    end

    # constructor-by-RGB
    def self.rgb_string(s)
      c = new
      s = s[1..-1] if s[0..0] == '#'
      if s.size == 3
        rs = s[0..0]+s[0..0]
        gs = s[1..1]+s[1..1]
        bs = s[2..2]+s[2..2]
      elsif s.size == 6
        rs = s[0..1]
        gs = s[2..3]
        bs = s[4..5]
      else
        raise ArgumentError, "Invalid color string [#{s}]"
      end
      c.set_rgb(rs.to_i(16), gs.to_i(16), bs.to_i(16))
      c
    end
    
    # constructor-by-name
    def self.name(color_name)
      c = new
      MAP[color_name.to_sym] or raise ArgumentError, "Color [#{color_name}] not known"
      c.set_rgb(*MAP[color_name.to_sym])
      c
    end
    
    # ordinal constructor (choose a color by its index in the list)
    def self.ord(i)
      k = MAP.keys
      name(k[i % k.size])
    end
    
    # set RGB components of the color
    def set_rgb(r, g, b)
      @r, @g, @b = r, g, b
    end
    
    # output color as a PGFplots string
    def as_pgfplots
      "{rgb:red,#{@r};green,#{@g};blue,#{@b}}"
    end
    
    # output color as a gnuplot string
    def as_gnuplot
      "rgb \"#%02x%02x%02x\"" % [@r*255, @g*255, @b*255]
    end
  end
end