module Grafikon
  class Axis
    attr_accessor :title, :grid
    
    def initialize(chart)
      @title = nil
      @chart = chart
    end
  end
end