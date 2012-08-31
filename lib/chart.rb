module Grafikon
  class Chart 
    
    def initialize(&block)
      @title = nil
      @axes = {
        :x1 => Axis.new(self),
        :y1 => Axis.new(self) 
      }
      @series = []
      
      instance_eval(&block)
    end
    
    def axes(xtitle, ytitle)
      @axes[:x1].title = xtitle
      @axes[:y1].title = ytitle
    end
    
    def size(w, h)
      @width, @height = w, h
    end
    
    def add(data, opts)
      s = Series.new(self)
      s.title = opts[:title]
      s.data = data
      @series << s
    end
    
    def add_diff(base, other, opts = {})
      data = []
      k1 = base.map{|x| x[0]}
      k2 = other.map{|x| x[0]}
      (k1 & k2).each do |x|
        v1 = base.find{|q| q[0] == x}[1]
        v2 = other.find{|q| q[0] == x}[1]
        data << [x, v2 - v1]
      end
      add(data, opts)
    end
    
    def autocomplete
      i = 0
      @series.each do |s|
        unless s.color
          s.color = Grafikon::Color::ord(i)
          i += 1
        end
      end
      @series.each do |s|
        unless s.mark
          s.mark = Grafikon::Mark::ord(i)
          i += 1
        end
      end
    end
    
    def pgfplots(filename = nil)
      autocomplete
      options = []
      options << "xlabel=#{@axes[:x1].title}"
      options << "ylabel=#{@axes[:y1].title}"
      if String === @width
        options << "width=#{@width}"
      elsif @width == :fill
        options << "width=\\textwidth"  
      end
      if String === @height
        options << "height=#{@height}"
      end
      # width=\\textwidth,height=8cm,xlabel=effective time (efd),font=\\small,ylabel=critical boron concentration (g/kg)
      s = %{
        \\begin{tikzpicture}
        \\begin{axis}[#{options * ","}]
      }
      @series.each do |series|
        s << series.as_pgfplots
      end
      s << %{
        \\end{axis}
        \\end{tikzpicture}      
      }
      
      # beautify a bit
      s = s.split("\n").map(&:lstrip) * "\n"   
      
      # output
      if filename
        File.open(filename, 'w') do |f|
          f.print s
        end
      else
        return s
      end
    end
    
  end

end