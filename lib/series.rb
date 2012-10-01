module Grafikon
  module Series
    class Generic
      attr_accessor :data, :mark, :color, :pattern, :line_width
      attr_writer :title
    
      def initialize(chart)
        @title = nil
        @chart = chart
        @color = nil
        @pattern = nil
        @mark = nil
        @line_width = 1
        @data = []
      end
      
      def title
        @title || '---'
      end
        
      def check
        Array === @data or raise ArgumentError, "Series data have to be an array"
        @data.each do |point|
          Array === point or raise ArgumentError, "Series data point has to be an array"
          point.size == 2 or raise ArgumentError, "Series data point has to be an array with 2 elements"
        end
        if Symbol === @color
          @color = Grafikon::Color::name(@color)
        end
        if Symbol === @mark
          @mark = Grafikon::Mark::new(@mark)
        end
      end

      def x_values
        @data.map{|x| x[0]}
      end
          
      def y_values
        @data.map{|x| x[1]}
      end
      
      def prune(n, remove_outliers = false)
        return if @data.empty?
        xmin, xmax = x_values.min, x_values.max
        new_data = []
        (0...n).each do |i|
          x1 = xmin + (xmax - xmin) / n *  i 
          x2 = xmin + (xmax - xmin) / n * (i+1) 
          y  = @data.select{|w| x1 <= w[0] and w[0] <= x2}.map{|w| w[1]}
          unless y.empty?
            if remove_outliers
              y.delete(y.min) unless y.count(y.min) > 0.1 * y.size
              y.delete(y.max) unless y.count(y.max) > 0.1 * y.size
            end
            unless y.empty?
              new_data << [x1, y.min]
              new_data << [x2, y.max]
              new_data << [x1, y.max]
              new_data << [x2, y.min]
            end
          end
        end
        @data = new_data
      end
      
    end
    
    class Line < Generic
      
      def as_pgfplots
        check
        lw = if @line_width and @line_width > 0
          "line width=#{@line_width}pt"
        else
          'only marks'
        end
        s = %{
          \\definecolor{tempcolor#{self.object_id}}{rgb}{#{color.r},#{color.g},#{color.b}}
          \\addplot[mark=#{@mark.as_pgfplots},color=tempcolor#{self.object_id},#{lw}] plot coordinates {
            #{@data.map{|q| "(%s,%f)" % [q[0].to_s, q[1].to_f]} * "\n"}
          };        
        }
        s
      end
    
    end
    
    class Bar < Generic
      
      def as_pgfplots
        check
        p = ""
        p = "," + @pattern.as_pgfplots if @pattern
        s = %{
          \\definecolor{tempcolor#{self.object_id}}{rgb}{#{color.r},#{color.g},#{color.b}}
          \\addplot[color=black,fill=tempcolor#{self.object_id}#{p}] coordinates {
            #{@data.map{|q| "(%s,%f)" % [q[0].to_s, q[1].to_f]} * "\n"}
          };        
        }
        s
      end
    
    end
  end
end