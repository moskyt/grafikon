module Grafikon
  class Axis
    attr_accessor :title
    
    def initialize(chart)
      @title = nil
      @chart = chart
    end
  end
end