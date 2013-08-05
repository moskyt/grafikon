require "grafikon/version"
require "grafikon/axis"
require "grafikon/chart"
require "grafikon/color"
require "grafikon/pattern"
require "grafikon/mark"
require "grafikon/series"

require 'guttapercha'

module Grafikon

  def self.gnuplot_escape(s)
    s.gsub("_", "\\_")
    s.gsub("\"", "\\\"")
  end

end