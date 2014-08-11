module Grafikon
  module Series
    # general chart series class 
    class Base
      # series data (array of points - 2- or 4-element arrays)
      attr_accessor :data
      # series mark (a Grafikon::Mark object or a symbol)
      attr_accessor :mark
      # series color (a Grafikon::Color object or a symbol)
      attr_accessor :color
      # line width in points
      attr_accessor :line_width
      # line type (currently as a number for gnuplot; not recogized by pgfplots plots)
      attr_accessor :line_type
      # mark size in points
      attr_accessor :mark_size
      # vertial axis selector (:primary or :secondary)
      attr_accessor :axis
      # extra PGF options
      attr_accessor :pgf_options
      # series label
      attr_writer :title

      def initialize(chart)
        @title = nil
        @pgf_options = nil
        @chart = chart
        @color = nil
        @mark = nil
	      @mark_size = 3
        @line_width = 1
        @line_type = nil
        @data = []
        @x_error_bars = nil
        @y_error_bars = nil
        @axis = :primary
      end

      #return the series label (or a three-dash string if no title is given)
      def title
        @title == :none ? nil : (@title.to_s || '---')
      end

      def check
        Array === @data or raise ArgumentError, "Series data have to be an array"
        @data.each do |point|
          Array === point or raise ArgumentError, "Series data point has to be an array"
          point.size == 2 or point.size == 4 or raise ArgumentError, "Series data point has to be an array with 2 or 4 elements"
        end
        if Symbol === @color
          @color = Grafikon::Color::name(@color)
        end
        if Symbol === @mark
          @mark = Grafikon::Mark::new(@mark)
        end
      end

      # format this series' options as a gnuplot option string
      def gnuplot_options
        opts = []

        if @line_width && @line_width > 0
          opts << "lw #{@line_width}"
          if @line_type
            opts << "lt #{@line_type}"
          end
        end

        opts << "lc #{@color.as_gnuplot}"
        opts << "pt #{@mark.as_gnuplot}" unless @mark.none?
        opts << "title \"#{@title}\"" if title
        opts << "axes x1y2" if @axis == :secondary

        opts
      end

      # build a CSV tempfile
      def csv_temp_file
        require 'tempfile'

        file = Tempfile.new('series_csv')

        @data.each do |ary|
          file.write((ary.map{|x| "%.5e" % x} * " ") + "\n")
        end

        file.close

        file
      end

      # return an array of x-values
      def x_values
        @data.map{|x| x[0]}
      end

      # return an array of y-values
      def y_values
        @data.map{|x| x[1]}
      end

      # convert the series to a step function (original data are in the centers of the steps)
      def stepify
        return if @data.empty?
        new_data = []
        (0...@data.size).each do |i|
          if i > 0
            new_data << [(@data[i-1][0] + @data[i][0])/2.0,@data[i][1]]
          end
          new_data << @data[i].dup
          if i+1 < @data.size
            new_data << [(@data[i+1][0] + @data[i][0])/2.0,@data[i][1]]
          end
        end
        @data = new_data
      end

      # prune the series; within each of the _n_ intervals choose the minimum and maximum value and make a bounding plot with (x1,min) and (x2,max) points for each interval
      #
      # the _opts_ hash can contain the following options:
      # 
      # :remove_outliers -- if true, removes all points with y outside the 2-sigma interval
      # :select -- can be :min or :max to select the minimum or maximum point, respectively
      def prune(n, opts)
        return if @data.empty?
        opts[:remove_outliers] = false unless opts.has_key?(:remove_outliers)

        xmin, xmax = x_values.min, x_values.max
        new_data = []
        (0...n).each do |i|
          x1 = xmin + (xmax - xmin) / n *  i
          x2 = xmin + (xmax - xmin) / n * (i+1)
          y  = @data.select{|w| x1 <= w[0] and w[0] <= x2}.map{|w| w[1]}
          unless y.empty?
            if opts[:remove_outliers] and y.size > 1
              avg = y.inject(0.0){|s,x| s+x} / y.size
              std = (y.inject(0.0){|s,x| s + (x-avg)**2} / (y.size - 1)) ** 0.5
              newy = y.select{|w| (w - avg).abs < 2*std}
              y = newy unless newy.empty?
            end
            unless y.empty?
              new_data << [x1, y.min] unless opts[:select] == :max
              new_data << [x2, y.max] unless opts[:select] == :min
            end
          end
        end
        @data = new_data
      end

    end

    # line series chart
    class Line < Base

      def initialize(chart)
        super(chart)
        @connect = :smooth
      end

      # segment connection type, can be either :straight, :smooth or :const (used only for pgfplots plots)
      def connect=(x)
        [:straight, :smooth, :const].include?(x) or raise ArgumentError, "Invalid connect [#{x}]"
        @connect = x
      end

      # set y errorbars; the available _options_ are:
      #  :direction -- can be :plus, :minus or :both
      def y_error_bars(options = {})
        @y_error_bars = {:direction => :both}.merge(options)
      end

      # check for validity and also sort the data according to the x-coord
      def check
        super
        @data = @data.sort_by{|x| x.first}
      end
      
      def gnuplot_options
        opts = ["using 1:2"] + super

        if @line_width && @line_width > 0 && @mark && !@mark.none?
          opts << "with linespoints"
        elsif @line_width && @line_width > 0
          opts << "with lines"
        else
          opts << "with points"
        end
        
      
        opts
      end

      # return the data as a pgfplots chart chunk
      def as_pgfplots
        check
        options = []

        options << "mark=#{@mark.as_pgfplots}"
        options << "color=rgbcolor%04d%04d%04d" % [color.r*1000, color.g*1000, color.b*1000]

        if @line_width and @line_width > 0
          options << "line width=#{@line_width}pt"
        else
          options << 'only marks'
        end

        if @mark_size and @mark_size > 0
          options << "mark size=#{@mark_size}pt"
        end


        case @connect
        when :smooth
          ""
        when :straight
          options << "straight plot"
        when :const
          options << "const plot"
        end

	      options += [@pgf_options].flatten if @pgf_options

        eb = ""
        if @y_error_bars
          d = case @y_error_bars[:direction]
          when :minus
            'minus'
          when :plus
            'plus'
          when :both
            'both'
          else
            raise "Invalid y error bar direction [#{@y_error_bars[:direction]}]"
          end
          eb = %{[error bars/.cd,y dir=#{d}]}
        end

        if @y_error_bars or @x_error_bars
          s = %{
            \\addplot[#{options * ','}] plot#{eb} coordinates {
              #{@data.map{|q| "(%s,%.5e) +- (%f,%.5e)" % [q[0].to_s, q[1].to_f, q[2].to_f, q[3].to_f]} * "\n"}
            };
          }
        else
          s = %{
            \\addplot[#{options * ','}] plot#{eb} coordinates {
              #{@data.map{|q| "(%s,%.5e)" % [q[0].to_s, q[1].to_f]} * "\n"}
            };
          }
        end
        s
      end

    end

    # bar chart series
    class Bar < Base

      # pattern for bar charts
      attr_accessor :pattern
      
      def initialize(chart)
        super(chart)
        @pattern = nil
      end
      
      def gnuplot_options
        opts = ["using 2:xticlabels(1)"] + super

        opts << "with histogram"

        opts
      end

      # return the data as a pgfplots chunk
      def as_pgfplots
        check
        p = "color=rgbcolor%04d%04d%04d" % [color.r*1000, color.g*1000, color.b*1000]
        p = "," + @pattern.as_pgfplots if @pattern
        s = %{
          \\addplot[color=black,fill=tempcolor#{self.object_id}#{p}] coordinates {
            #{@data.map{|q| "(%s,%.5e)" % [q[0].to_s, q[1].to_f]} * "\n"}
          };
        }
        s
      end

    end
  end
end
