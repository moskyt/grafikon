module Grafikon
  module Series
    class Generic
      attr_accessor :data, :mark, :color
      attr_writer :title
    
      def initialize(chart)
        @title = nil
        @chart = chart
        @color = nil
        @mark = nil
        @data = []
      end
      
      def title
        @title || '---'
      end
        
      def check
        Array === @data or raise "Series data have to be an array"
        @data.each do |point|
          Array === point or raise "Series data point has to be an array"
          point.size == 2 or raise "Series data point has to be an array with 2 elements"
        end
      end

      def x_values
        @data.map{|x| x[0]}
      end
          
      def y_values
        @data.map{|x| x[1]}
      end
      
    end
    
    class Line < Generic
      
      def as_pgfplots
        check
         s = %{
          \\addplot[smooth,mark=#{@mark.as_pgfplots},color=#{@color.as_pgfplots}] plot coordinates {
            #{@data.map{|q| "(%s,%f)" % [q[0].to_s, q[1].to_f]} * "\n"}
          };        
        }
        s
      end
    
    end
    
    class Bar < Generic
      
      def as_pgfplots
        check
         s = %{
          \\addplot[color=#{@color.as_pgfplots},fill=#{@color.as_pgfplots}] coordinates {
            #{@data.map{|q| "(%s,%f)" % [q[0].to_s, q[1].to_f]} * "\n"}
          };        
        }
        s
      end
    
    end
  end
end