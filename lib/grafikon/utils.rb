module Grafikon
  module Utils
    def montage(images, x, y, output, preserve = false)
      system("montage #{images * " "} -geometry +#{x}+#{y} #{output}")
      images.each{|x| File.delete(x)} unless preserve
    end
  end
end
