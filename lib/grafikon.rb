require_relative "grafikon/version"
require_relative "grafikon/axis"
require_relative "grafikon/chart"
require_relative "grafikon/color"
require_relative "grafikon/pattern"
require_relative "grafikon/mark"
require_relative "grafikon/series"

module Grafikon

  def self.gnuplot_escape(s)
    s.gsub("_", "\\_")
    s.gsub("\"", "\\\"")
  end

end