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

excludes = %w[2014-07-19]

info_text = "As of #{Date.today}\n@yuri_koval"

dir = File.expand_path(File.dirname(__FILE__))
images_dir = File.join dir, 'img'

puts "Reading images in #{images_dir}"
sizes.each do |x, y, delay|
  export_file_path = File.join dir, "ukraine-ato-#{Date.today}-#{x}x#{y}-#{delay}f.gif"
  animation = ImageList.new()
  Dir[File.join images_dir, "*.jpg"].each do |image_path|
    if excludes.select{ |exclude| image_path =~ /#{exclude}\.jpg$/ }.any?
      puts "Skipping #{image_path}  *   *   *"
      next
    end
    full_image = Magick::Image::read(image_path).first
    # resize image
    timeline_height = [5, (y / 200).round].max
    resized_image = full_image.resize_to_fill(x, y).extent(x, y + timeline_height)

    # add watermark
    pointsize = (y / 20).round
    watermark = Magick::Image.new(x, y + timeline_height) do
      self.background_color = 'none'
    end
    watermark.alpha(Magick::ActivateAlphaChannel)
    watermark_text = Magick::Draw.new
    watermark_text.annotate(watermark, 0,0,0,timeline_height, info_text) do
      watermark_text.gravity = SouthWestGravity
      self.pointsize = pointsize
      self.font_family = "Helvetica"
      self.stroke = "none"
    end
    resized_image.composite!(watermark, SouthWestGravity, OverCompositeOp)

    animation << resized_image
    puts "Processed #{image_path}"
  end

  puts "Writing to #{export_file_path}"
  animation.delay = delay
  animation.write(export_file_path)
  animation.destroy!
end
puts "DONE."
