module Grafikon
  class Series
    attr_accessor :title
    
    def initialize(chart)
      @title = nil
      @chart = chart
      @color = nil
      @data = []
    end
    
    def check
      Array === @data or raise "Series data have to be an array"
      @data.each do |point|
        Array === point or raise "Series data point has to be an array"
        point.size == 2 or raise "Series data point has to be an array with 2 elements"
      end
    end
    
    def as_pgfplots
       %{
        \\addplot[smooth,mark=#{@mark.to_s(:pgfplots)},#{@color.to_s(:pgfplots)}] plot coordinates {
          #{@data.map{|q| "(%.1f,%.3f)" % q} * "\n"}
        };
        \\addlegendentry{#{@title}}
      }      
    end
    
  end
end