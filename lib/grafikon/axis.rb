module Grafikon
  # An axis wrapper for defining limits, axis labels or ticks
  class Axis
    
    # axis type - :x or :y
    attr_reader :type
    
    # axis label
    attr_accessor :title
    
    # grid lines setting on this axis, can be nil, :minor, :major or :both
    attr_accessor :grid
    
    # axis minimum/maximum limits; can be nil (or :auto) or a 2-floats array
    attr_accessor :limits
    
    # extra ticks on this axis; an array of 2-element arrays where the first element is the tick position and the second one is the tick label
    attr_accessor :ticks

    def initialize(type, chart)
      @type = type
      @title = nil
      @limits = nil
      @ticks = nil
      @chart = chart
    end

    def pgf_options
      
      require 'guttapercha'
      
      set = []
      case @limits
      when nil, :auto
      when Array
        set.size != 2 or raise ArgumentError, "Two fields must be given for axis limits"
        set << "#{type}min=#{@limits[0]}" if @limits[0]
        set << "#{type}max=#{@limits[1]}" if @limits[1]
      else
        raise ArgumentError, "? #{@limits.inspect}"
      end

      case @grid
      when nil
      when :minor, :both
        set << "#{type}minorgrids=true"
      when :major, :both
        set << "#{type}majorgrids=true"
      else
        raise "? #{@grid}"
      end

      if @ticks
        set << "#{type}tick={#{@ticks.map{|x| x[0].to_s}*','}}"
        set << "#{type}ticklabels={#{@ticks.map{|x| '{'+LaTeX::escape(x[1].to_s)+'}'}*','}}"
      end

      set << "#{type}label={#{LaTeX::escape @title}}"

      set
    end
  end
end