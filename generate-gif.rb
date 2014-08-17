#!/usr/bin/env ruby

#  Generate scaled GIF images
#    by Yuri Kovalov
#    yuri@yurikoval.com
#    http://www.yurikoval.com

require "rubygems"
require "rmagick"
require "date"
include Magick

# X, Y, delay
sizes = [
  [300, 250, 50],
  [800, 667, 50],
]

dir = File.expand_path(File.dirname(__FILE__))
images_dir = File.join dir, 'img'

puts "Reading images in #{images_dir}"
sizes.each do |x, y, delay|
  export_file_path = File.join dir, "ukraine-ato-#{Date.today}-#{x}x#{y}-#{delay}f.gif"
  animation = ImageList.new()
  Dir[File.join images_dir, "*.jpg"].each do |image_path|
    full_image = Magick::Image::read(image_path).first
    animation << full_image.resize_to_fill(x, y)
    puts "Processed #{image_path}"
  end

  puts "Writing to #{export_file_path}"
  animation.delay = delay
  animation.write(export_file_path)
  animation.destroy!
end
puts "DONE."
