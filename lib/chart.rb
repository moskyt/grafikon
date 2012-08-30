module Grafikon
  class Chart 
    
    def initialize(block)
      @title = nil
      @axes = {
        :x1 => Axis.new(self),
        :y1 => Axis.new(self) 
      }
      @series = []
      
      instance_eval(&block)
    end
    
    def pgfplots
    end
    
  end

end