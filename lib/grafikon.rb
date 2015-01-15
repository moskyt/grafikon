require_relative "grafikon/version"
require_relative "grafikon/axis"
require_relative "grafikon/chart"
require_relative "grafikon/color"
require_relative "grafikon/pattern"
require_relative "grafikon/mark"
require_relative "grafikon/utils"
require_relative "grafikon/series"

module Grafikon

  # set of gnuplot-related helpers
  module Gnuplot
    # escape a string for use in gnuplot (titles, labels...)
    def self.escape(s)
      s.gsub("_", "\\_").gsub("\"", "\\\"")
    end
  end

end