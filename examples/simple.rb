require_relative '../lib/grafikon'

a = (1..6).map{|x| [x,x]}
b = (1..6).map{|x| [x,x**1.5]}

puts(Grafikon::Chart.new do
  size :fill, '8cm'
  add a, :title => 'linear', :mark => :x
  add a, :title => 'linear-and-half', :color => :gray
end.pgfplots)

puts(Grafikon::Chart.new do
  axes 'x-value', 'y-value'
  size :fill, '8cm'
  add_diff a, b
end.pgfplots)