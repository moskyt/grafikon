require 'minitest/autorun'
require 'minitest/unit'
require 'minitest/pride'

require 'grafikon'

class TestBasic < MiniTest::Unit::TestCase

  def test_line_chart

    a = (1..6).map{|x| [x,x]}
    b = (1..6).map{|x| [x,x**1.5]}
    d = (1..6).map{|x| [x,1000*x**0.5]}

    c = Grafikon::Chart::Line.new do
      title "an exam_ple"
      size :fill, '8cm'
      add a, :title => 'linear', :mark => :x
      add b, :title => 'linear-and-half', :color => :gray, :mark => :Circle
      add d, :title => 'rooty', :mark => :none, :axis => :secondary
      add [[1,1],[5,3],[2.5,2]], :title => 'sorty', :color => :red
    end

    # pgfplots string
    c.pgfplots
 
    # gnuplot string
    c.gnuplot(:format => :png)
    # run gnuplot 
    c.gnuplot(:format => :png, :output => 'test_line_chart.png')

    # gnuplot string
    c.gnuplot(:format => :eps)
    # run gnuplot 
    c.gnuplot(:format => :eps, :output => 'test_line_chart.eps')
    
  end
  
end