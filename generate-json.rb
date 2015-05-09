#!/usr/bin/env ruby

#  Generate image JSON
#    by Yuri Kovalov
#    yuri@yurikoval.com
#    http://www.yurikoval.com

require 'date'
require 'json'

dir = File.expand_path(File.dirname(__FILE__))
images_dir = File.join dir, 'img'
json_file = File.join images_dir, "images.json"

images = Dir[File.join images_dir, "*.jpg"].map do |image_path|
  filename = File.basename image_path
  {
    path: (image_path.sub "#{dir}/", ''),
    date: Date.parse(filename)
  }
end

puts "Writing to #{json_file}"
write_json = {
  images: images
}

File.open(json_file, "w") do |f|
  f.write(write_json.to_json)
end