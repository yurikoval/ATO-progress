#!/usr/bin/env ruby

#  Generate scaled GIF images
#    by Yuri Kovalov
#    yuri@yurikoval.com
#    http://www.yurikoval.com

require "rubygems"
require "rmagick"
require "date"
include Magick

x = 600
y = 500
delay = 50

dir = File.expand_path(File.dirname(__FILE__))
images_dir = File.join dir, 'img'
export_file_path = File.join dir, "ukraine-ato-#{Date.today}-#{x}x#{y}-#{delay}f.gif"

puts "Reading images in #{images_dir}"

animation = ImageList.new()

Dir[File.join images_dir, "*.jpg"].each do |image_path|
  full_image = Magick::Image::read(image_path).first
  animation << full_image.resize_to_fill(x, y)
  puts "Processed #{image_path}"
end

puts "Writing to #{export_file_path}"
animation.delay = delay
animation.write(export_file_path)
puts "DONE."
