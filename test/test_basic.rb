require 'minitest/autorun'
require 'minitest/unit'
require 'minitest/pride'

require 'grafikon'

class TestBasic < MiniTest::Unit::TestCase

  def test_chart_block
    a = (1..6).map{|x| [x,x]}

    Grafikon::Chart::Line.new do
      add a, :title => 'linear', :mark => :x
    end.gnuplot(:format => :png, :output => 'test_chart_block.png')
  end
  
  def test_line_diff
    a = (1..6).map{|x| [x,x]}
    b = (1..6).map{|x| [x,x ** 1.5]}

    c = Grafikon::Chart::Line.new do
      title "an exam_ple"
      size :fill, '8cm'
      add a, :title => 'linear', :mark => :x
      add b, :title => 'linear-and-half', :color => :gray, :mark => :Circle
      add_diff a, b, :title => 'difference', :mark => :Square, :color => :red, :axis => :secondary
    end

    # pgfplots file
    c.pgfplots('test_line_diff.tex')
  end

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