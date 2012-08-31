module Grafikon
  class Series
    attr_accessor :title, :data, :mark, :color
    
    def initialize(chart)
      @title = nil
      @chart = chart
      @color = nil
      @mark = nil
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
      check
       s = %{
        \\addplot[smooth,mark=#{@mark.as_pgfplots},color=#{@color.as_pgfplots}] plot coordinates {
          #{@data.map{|q| "(%.1f,%.3f)" % q} * "\n"}
        };        
      }
      s << "\\addlegendentry{#{@title}}" if @title   
      s   
    end
    
  end
end