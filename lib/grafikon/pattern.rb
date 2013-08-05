module Grafikon
  class Pattern
    
    def as_pgfplots(pgfword)
      %{
        postaction={
          pattern=#{pgfword}
        }
      }
    end
    
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
  
  class HatchPattern < Pattern
    def as_pgfplots
      super('north east lines')
    end
  end
  
  class CrossHatchPattern < Pattern
    def as_pgfplots
      super('crosshatch')
    end
  end
  
  class GridPattern < Pattern
    def as_pgfplots
      super('grid')
    end
  end
end