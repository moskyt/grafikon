module Grafikon
  class Axis
    attr_reader :type
    attr_accessor :title, :grid, :limits, :ticks

    def initialize(type, chart)
      @type = type
      @title = nil
      @limits = nil
      @ticks = nil
      @chart = chart
    end

    def options
      
      require 'guttapercha'
      
      set = []
      case @limits
      when nil, :auto
      when Array
        set << "#{type}min=#{@limits[0]}" if @limits[0]
        set << "#{type}max=#{@limits[1]}" if @limits[1]
      else
        raise "? #{@limits.inspect}"
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