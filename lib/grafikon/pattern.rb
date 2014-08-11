module Grafikon
  # superclass for chart fill patterns
  class Pattern
    
    # return the pattern as a pgfplots chunk (a wrapper)
    def as_pgfplots(pgfword)
      %{
        postaction={
          pattern=#{pgfword}
        }
      }
    end
    
    # factory for patterns
    # the supported patterns are :grid, :hatch and :crosshatch
    def self.name(name)
      case name
      when nil
        nil
      when :grid
        GridPattern.new
      when :hatch
        HatchPattern.new
      when :crosshatch
        CrossHatchPattern.new
      else
        raise ArgumentError, "Pattern [#{name}] not known"
      end
    end
    
  end
  
  # hatch pattern (slash-like)
  class HatchPattern < Pattern
    def as_pgfplots
      super('north east lines')
    end
  end
  
  # cross-hatch pattern (SW-NE and NW-SE lines)
  class CrossHatchPattern < Pattern
    def as_pgfplots
      super('crosshatch')
    end
  end
  
  # cross-hatch pattern (N-E and W-E lines)
  class GridPattern < Pattern
    def as_pgfplots
      super('grid')
    end
  end
end