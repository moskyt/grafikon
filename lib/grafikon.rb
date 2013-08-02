require_relative 'axis'
require_relative 'chart'
require_relative 'color'
require_relative 'pattern'
require_relative 'mark'
require_relative 'series'

require 'guttapercha'

module Grafikon

  def gnuplot_escape(s)
    s.gsub("_", "\\_")
    s.gsub("\"", "\\\"")
  end
  

end