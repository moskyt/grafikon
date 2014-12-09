module Grafikon
  module Chart

    # generic chart class
    class Base

      # constructor; can take a block, which is evaluated within the instance context
      def initialize(&block)
        @title = nil
        @axes = {
          :x1 => Axis.new(:x,self),
          :y1 => Axis.new(:y,self),
          :y2 => Axis.new(:y,self),
          :z1 => Axis.new(:z,self)
        }
        @series = []
        @legend = :outer_next
        @legend_columns = -1
        @x_grid = nil
        @y_grid = :major
        @z_grid = :major
        @scale_only_axis = true
        @extra_pgf_options = []
        @pgf_commands = ''
        # extra_pgf_options "yticklabel style={/pgf/number format/fixed}"
        extra_pgf_options "scaled ticks=false"

        @color_pool = []

        instance_eval(&block) if block_given?
      end

      # plot the chart using gnuplot
      # options can be:
      #   :format -- output format (gnuplot terminal), can be :eps or :png (640x480), :png_medium (1280x960), :png_large (1920x1440)
      #   :output -- output filename; if given, gnuplot is executed -- otherwise the gnuplot input deck is returned with no action taken
      def gnuplot(options)
        autocomplete
        @series.each(&:check)
        series_files = @series.map(&:csv_temp_file)
        series_list = []
        @series.each_with_index do |s,i|
          s.check
          series_list << %{"#{series_files[i].path}" #{s.gnuplot_options * " "}}
        end

        plot_string = ""
        case options[:format]
        when :png
          plot_string << "set terminal png enhanced medium size 640,480\n"
        when :png_medium
          plot_string << "set terminal png enhanced medium size 1280,960\n"
        when :png_large
          plot_string << "set terminal png enhanced medium size 1920,1440\n"
        when :eps
          plot_string << "set terminal postscript eps enhanced color dashed\n"
        when :aqua
          plot_string << "set terminal x11\n"
        when nil
          raise ArgumentError, "gnuplot format not given"
        else
          raise ArgumentError, "unknown gnuplot format: #{options[:format]}"
        end

        gnuplot_options.each do |x|
          plot_string << x << "\n"
        end

        if @title
          plot_string << "set title '#{Grafikon::Gnuplot::escape @title}' noenhanced\n"
        end

        case @legend
        when :outer_next
          plot_string << "set key outside top right\n"
        when :top_right
          plot_string << "set key inside top right\n"
        when :bottom_right
          plot_string << "set key inside bottom right\n"
        when :outer_below
          plot_string << "set key below\n"
        when nil
          plot_string << "set nokey\n"
        else
          raise "? #{@legend}"
        end

        pseries, sseries = * @series.partition{|x| x.axis == :primary}

        unless sseries.empty?
          plot_string << "set y2tics\n"
        end
        if @axes[:x1].title
          plot_string << "set xlabel \"#{Grafikon::Gnuplot::escape @axes[:x1].title}\" noenhanced\n"
        end
        if @axes[:y1].title
          plot_string << "set ylabel \"#{Grafikon::Gnuplot::escape @axes[:y1].title}\" noenhanced\n"
        end
        if @axes[:y2].title
          plot_string << "set y2label \"#{Grafikon::Gnuplot::escape @axes[:y2].title}\" noenhanced\n"
        end
        if l = @axes[:y1].limits
          plot_string << "set yrange [#{l.first}:#{l.last}]\n"
        end
        if l = @axes[:y2].limits
          plot_string << "set y2range [#{l.first}:#{l.last}]\n"
        end
        plot_string << "plot #{series_list * ','}\n"
        if options[:output]
          plot_string = %{set output "#{options[:output]}"\n} + plot_string
          p = Tempfile.new('pfile')
          p.write plot_string
          p.close
          `gnuplot #{p.path}`
        end
        plot_string
      end

      def add_color(r,g,b)
        @color_pool << [[r,g,b]]
      end

      def extra_pgf_options(*opts)
        @extra_pgf_options += opts
      end

      def title(x)
        @title = x.to_s
      end

      def x_grid(x)
        raise ArgumentError, "Bad x-grid option [#{x}]" unless [nil, :minor, :major, :both].include?(x)
        @axes[:x1].grid = x
      end

      def y_grid(y)
        raise ArgumentError, "Bad y-grid option [#{y}]" unless [nil, :minor, :major, :both].include?(y)
        @axes[:y1].grid = y
      end

      def y2_grid(y)
        raise ArgumentError, "Bad y-grid option [#{y}]" unless [nil, :minor, :major, :both].include?(y)
        @axes[:y2].grid = y
      end

      def axes(xtitle, ytitle, y2title = nil, ztitle = nil)
        x_axis(xtitle)
        y_axis(ytitle)
        y2_axis(y2title)
        z_axis(ztitle)
      end

      # set title for the horizontal (X) axis
      def x_axis(xtitle)
        @axes[:x1].title = xtitle
      end

      # set title for the primary vertical (Y) axis
      def y_axis(ytitle)
        @axes[:y1].title = ytitle
      end

      def z_axis(ztitle)
        @axes[:z1].title = ztitle
      end

      # set title for the secondary vertical (Y2) axis
      def y2_axis(y2title)
        @axes[:y2].title = y2title
      end

      # set minimum and maximum limit for the primary vertical (Y) axis; any of the limits can be nil to use auto setting
      def y_limits(min, max)
        @axes[:y1].limits = [min, max]
      end

      # set minimum and maximum limit for the secondary vertical (Y2) axis; any of the limits can be nil to use auto setting
      def y2_limits(min, max)
        @axes[:y2].limits = [min, max]
      end

      # set minimum and maximum limit for the horizontal (X) axis; any of the limits can be nil to use auto setting
      def x_limits(min, max)
        @axes[:x1].limits = [min, max]
      end

      # set legend position and some of its options
      # possible values for _position_:
      #  :outer_next  -- outside the chart, upper right corner
      #  :outer_below -- below the chart, centered
      #  :top_right   -- inside the chart, upper right corner
      #  :bottom_right -- inside the chart, bottom right corner
      #
      # available _options_ are:
      #  :columns -- number of columns in the legend; -1 by default
      def legend(position, options = {})
        @legend = position
        if options[:columns]
          @legend_columns = options.delete(:columns)
        end
        options.empty? or raise ArgumentError, "Did not recognize the following options for legend: #{options.keys.inspect}"
      end

      def z_limits(a,b)
        @axes[:z1].limits = [a,b]
      end

      # set number of columns in the legend
      def legend_columns(x)
        @legend_columns = x
      end

      def x_ticks(set)
        @axes[:x1].ticks = set
      end

      def z_ticks(set)
        @axes[:z1].ticks = set
      end

      def size(w, h, scale_only_axis = true)
        @width, @height, @scale_only_axis = w, h, scale_only_axis
      end

      # create a new data series (appropriate Grafikon::Series subclass) and add it to the chart. _data_ is an array of [x,y] pairs
      # all of the options are treated as writers for the series object, i.e {:x => y} translates to s.x = y
      # optionally a block can be supplied, which is then evaluated within the context of the series object
      def add(data, opts = {})
        return false if data.empty?
        s = self.class.series_class.new(self)
        opts.keys.each do |key|
          if s.respond_to?(:"#{key}=")
            s.send(:"#{key}=", opts.delete(key))
          end
        end
        unless opts.keys.empty?
          raise ArgumentError, "Did not understand series options #{opts.keys.inspect}"
        end
        s.data = data.reject do |x|
          x.any?(&:nil?)
        end

        if block_given?
          s.instance_eval(&Proc.new)
        end
        @series << s
      end

      def pgf_node str
        @pgf_commands << "\\node " << str << ";\n"
      end

      def pgf_fill str
        @pgf_commands << "\\fill " << str << ";\n"
      end

      def pgf_draw str
        @pgf_commands << "\\draw " << str << ";\n"
      end

      def add_diff(base, other, opts = {})
        data = []
        m = opts.delete(:multiplier) || 1.0
        t = opts.delete(:tolerance) || 1e-5
        int = opts.delete(:interpolate)
        base.reject! do |x,y|
          not x && y
        end
        other.reject! do |x,y|
          not x && y
        end
        k1 = base.map{|x| x[0]}
        k2 = other.map{|x| x[0]}
        (k1 + k2).sort.uniq.each do |x|
          if int
            v1 = interpolate_in(base.transpose.first, base.transpose.last, x)
            v2 = interpolate_in(other.transpose.first, other.transpose.last, x)
          else
            v1 = base.find{ |q| (q[0]-x).abs < t}
            v2 = other.find{|q| (q[0]-x).abs < t}
          end
          if v1 and v2
            v1 = v1[1]
            v2 = v2[1]
            data << [x, (v2 - v1)*m]
          end
        end
        add(data, opts)
      end

      def add_rdiff(base, other, opts = {})
        data = []
        m = opts.delete(:multiplier) || 100.0
        t = opts.delete(:tolerance) || 1e-5
        int = opts.delete(:interpolate)
        k1 = base.map{|x| x[0]}
        k2 = other.map{|x| x[0]}
        (k1 + k2).sort.uniq.each do |x|
          if int
            v1 = interpolate_in(base.transpose.first, base.transpose.last, x)
            v2 = interpolate_in(other.transpose.first, other.transpose.last, x)
          else
            v1 = base.find{ |q| (q[0]-x).abs < t}
            v2 = other.find{|q| (q[0]-x).abs < t}
          end
          if v1 and v2
            v1 = v1[1]
            v2 = v2[1]
            data << [x, (v2/v1-1)*m]
          end
        end
        add(data, opts)
      end

    protected

      def gnuplot_options
        []
      end

      def pgfplots_legend_options
        set = ["legend style={anchor=west}"]
        case @legend
        when :outer_next
          set << "legend pos=outer north east"
        when :top_right
          set << "legend pos=north east"
        when :bottom_right
          set << "legend pos=south east"
        when :outer_below
          set << "legend style={at={(0.5,-0.25)},anchor=north,legend columns=-1}"
        when nil
        else
          raise "? #{@legend}"
        end
        set
      end

      def size_options
        require 'guttapercha'

        options = @extra_pgf_options
        options << "scale only axis" if @scale_only_axis
        if @title and !@title.empty?
          options << "title={#{LaTeX::escape @title}}"
        end
        if @width
          if String === @width
            options << "width={#{@width}}"
          elsif @width == :fill
            options << "width={\\textwidth}"
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

      # write the _data_ to file if _filename_ is given; return just the beautified _data_ instead
      def pgf_output(filename, data)
        # beautify a bit
        s = data.split("\n").map(&:lstrip) * "\n"

        # output
        if filename
          filename.kind_of?(String) or raise ArgumentError, "Filename #{filename.inspect} is not a string!"
          File.open(filename, 'w') do |f|
            f.print s
          end
        else
          return s
        end
      end

    protected

      # add colors and marks to all series in this chart
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

      # an interpolation helper. For a given vector of x-values _xx_ and a vector of y-values _yy_, find an y-value corresponding to the x-value _x_
      def interpolate_in(xx, yy, x)
        return nil if xx.min > x
        return nil if xx.max < x
        i1 = xx.index {|q| q >= x}
        i2 = xx.rindex{|q| q <= x}
        return [x, yy[i1]] if (i1 == i2)
        x1, y1 = xx[i1], yy[i1]
        x2, y2 = xx[i2], yy[i2]
        [x, y1 + (x - x1) * (y2 - y1) / (x2 - x1)]
      end

    end

    class Bar < Base

      # :nodoc:
      def self.series_class
        Series::Bar
      end

      def gnuplot_options
        super + ["set style fill solid 1.0 border -1"]
      end

      # plot the chart using pgfplots
      def pgfplots(filename = nil)
        require 'guttapercha'

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
        options += pgfplots_legend_options
        options += @axes[:x1].pgf_options
        options += @axes[:y1].pgf_options

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
        s << @pgf_commands
        s << %{
          \\end{axis}
          \\end{tikzpicture}
        }
        pgf_output(filename, s)
      end
    end

    class Line < Base

      # :nodoc:
      def self.series_class
        Series::Line
      end

      def pgfplots(filename = nil, opts = {})
        require 'guttapercha'

        autocomplete
        options = []
        options << "compat=newest"

        options += size_options
        options += pgfplots_legend_options
        options += @axes[:x1].pgf_options

        if opts[:force_width]
          s = "\\resizebox{#{opts[:force_width]}}{!}{%
          \\begin{tikzpicture}%"
        else
          s = %{
            \\begin{tikzpicture}}
        end

        s << "\\tikzstyle{every node}=[font=\\#{opts[:font]}]" if opts[:font]

        @series.each do |series|
          series.check
          # series.sort
          s << %{\n\\definecolor{rgbcolor%04d%04d%04d}{rgb}{%.3f,%.3f,%.3f}} % [series.color.r*1000, series.color.g*1000, series.color.b*1000, series.color.r, series.color.g, series.color.b]
        end

        pseries, sseries = * @series.partition{|x| x.axis == :primary}
        only_primary = sseries.empty?
        [[pseries, :y1], [sseries, :y2]].each do |series_list, axis|
          secondary = (axis == :y2)
          if series_list.any?
            options_local = options + @axes[axis].pgf_options
            options_local << "axis y line*=left" if !only_primary and !secondary
            options_local << "axis y line*=right" << "axis x line=none" if secondary
            s << %{
              \\begin{axis}[#{options_local * ","}]
            }

            if @legend and secondary and !only_primary
              pseries.each_with_index do |series, i|
                s << "\\addlegendimage{/pgfplots/refstyle=refplot#{self.object_id}#{i}}\\addlegendentry{#{LaTeX::escape(series.title)} }\n" if series.title
              end
            end

            series_list.each_with_index do |series, i|
              s << series.as_pgfplots
              if (only_primary or secondary) and @legend
                s << "\\addlegendentry{#{LaTeX::escape(series.title)}}\n" if series.title
              elsif !secondary and @legend
                s << "\\label{refplot#{self.object_id}#{i}}\n"
              end
            end

            s << @pgf_commands

            s << %{
              \\end{axis}
            }
          end
        end

        s << %{
          \\end{tikzpicture}}
        s << "}" if opts[:force_width]
        s << "\n"
        pgf_output(filename, s)
      end
    end
  end

end
