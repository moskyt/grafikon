module Grafikon
  module Chart
    class Generic 
    
      def initialize(&block)
        @title = nil
        @axes = {
          :x1 => Axis.new(self),
          :y1 => Axis.new(self) 
        }
        @series = []
        @legend = :outer_next
        @xgrid = nil
        @ygrid = :major
        @scale_only_axis = true
        @x_ticks = nil
        @extra_pgf_options = []
      
        instance_eval(&block) if block_given?
      end
      
      def extra_pgf_options(*opts)
        @extra_pgf_options += opts
      end
      
      def title(x)
        @title = x
      end
    
      def x_grid(x)
        raise ArgumentError, "Bad x-grid option [#{x}]" unless [nil, :minor, :major, :both].include?(x)
        @x_grid = x
      end

      def y_grid(y)
        raise ArgumentError, "Bad y-grid option [#{y}]" unless [nil, :minor, :major, :both].include?(y)
        @y_grid = y
      end
    
      def axes(xtitle, ytitle)
        x_axis(xtitle)
        y_axis(ytitle)
      end
      
      def x_axis(xtitle)
        @axes[:x1].title = xtitle
      end

      def y_axis(ytitle)
        @axes[:y1].title = ytitle
      end
      
      def y_limits(a,b)
        @y_limits = [a,b]
      end
      
      def legend(x)
        @legend = x
      end
      
      def x_ticks(set)
        @x_ticks = set
      end
      
      def size(w, h, scale_only_axis = true)
        @width, @height, @scale_only_axis = w, h, scale_only_axis
      end
    
      def add(data, opts = {})
        return false if data.empty?
        s = self.class.series_class.new(self)
        opts.each do |key, val|
          if s.respond_to?(:"#{key}=")
            s.send(:"#{key}=", val)
          end
        end
        s.data = data
        if block_given?
          s.instance_eval(&Proc.new)
        end
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
    
    protected
    
      def legend_options
        set = ["legend style={anchor=west}"]
        case @legend 
        when :outer_next
          set << "legend pos=outer north east"
        when :outer_below
          set << "legend style={at={(0.5,-0.15)},anchor=north,legend columns=-1}"
        when nil
        else
          raise "? #{@legend}"
        end
        set
      end
      
      def axis_options
        set = []
        case @y_limits
        when nil, :auto
        when Array
          set << "ymin=#{@y_limits[0]}"
          set << "ymax=#{@y_limits[1]}"
        else 
          raise "? #{@y_limits.inspect}"
        end
        if @x_ticks
          set << "xtick={#{@x_ticks.map{|x| x[0].to_s}*','}}"
          set << "xticklabels={#{@x_ticks.map{|x| x[1].to_s}*','}}"
        end
        set
      end
      
      def grid_options
        set = []

        case @xgrid
        when nil
        when :minor, :both
          set << "xminorgrids=true"
        when :major, :both
          set << "ymajorgrids=true"
        else
          raise "? #{@xgrid}"
        end

        case @ygrid
        when nil
        when :minor, :both
          set << "yminorgrids=true"
        when :major, :both
          set << "ymajorgrids=true"
        else
          raise "? #{@ygrid}"
        end

        set
      end
      
      def size_options
        options = @extra_pgf_options
        options << "scale only axis" if @scale_only_axis
        if @title and !@title.empty?
          options << "title={#{@title}}"
        end
        if @width
          if String === @width
            options << "width=#{@width}"
          elsif @width == :fill 
            options << "width=\\textwidth"  
          else
            raise ArgumentError, "Cannot understand width [#{@width}]"
          end
        end
        if @height
          if String === @height
            options << "height=#{@height}"
          else
            raise ArgumentError, "Cannot understand height [#{@height}]"
          end
        end

        options
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
    
      def output(filename, s)
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
    
    class Bar < Generic
      
      def self.series_class
        Series::Bar
      end
      
      def pgfplots(filename = nil)
        autocomplete
        options = []
        
        options << "ybar=4pt"
        options << "enlargelimits=0.3"
        options << "ylabel={#{LaTeX::escape @axes[:y1].title}}" if @axes[:y1].title and !@axes[:y1].title.empty?
        options << "xtick=data"
        options << "symbolic x coords = {#{@series.map(&:x_values).flatten.uniq * ','}}"

        if @series.map(&:y_values).flatten.max < 0
          options << "ymax=0"
        end
        if @series.map(&:y_values).flatten.min > 0
          options << "ymin=0"
        end
        
        options += size_options
        options += legend_options
        options += grid_options
        options += axis_options
        
        s = %{
          \\begin{tikzpicture}
          \\begin{axis}[#{options * ","}]
        }
        @series.each do |series|
          s << series.as_pgfplots
        end
        s << %{
          \\legend{#{@series.map{|x| x.title.gsub("_",'-')} * ','}}
        } if @legend
        s << %{
          \\end{axis}
          \\end{tikzpicture}      
        }
        output(filename, s)
      end
    end
    
    class Line < Generic

      def self.series_class
        Series::Line
      end

      def pgfplots(filename = nil)
        autocomplete
        options = []
        options << "xlabel={#{LaTeX::escape @axes[:x1].title}}"
        options << "ylabel={#{LaTeX::escape @axes[:y1].title}}"

        options += size_options
        options += legend_options
        options += grid_options
        options += axis_options

        s = %{
          \\begin{tikzpicture}
          \\begin{axis}[#{options * ","}]
        }
        @series.each do |series|
          s << series.as_pgfplots
          s << "\\addlegendentry{#{series.title}}" if series.title and @legend
        end
        s << %{
          \\end{axis}
          \\end{tikzpicture}      
        }
      
        output(filename, s)
      end
    end
  end

end