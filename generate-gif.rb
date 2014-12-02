#!/usr/bin/env ruby

#  Generate scaled GIF images
#    by Yuri Kovalov
#    yuri@yurikoval.com
#    http://www.yurikoval.com

require "rubygems"
require "rmagick"
require "date"
include Magick

# X, Y, delay, name
sizes = [
  [150, 125, 50, 'ukraine-ato-current-tiny'],
  [300, 250, 50, 'ukraine-ato-current-small'],
  [800, 667, 50, 'ukraine-ato-current'],
]

excludes = %w[2014-07-19]


dir = File.expand_path(File.dirname(__FILE__))
images_dir = File.join dir, 'img'

puts "Reading images in #{images_dir}"
sizes.each do |x, y, delay, filename|
  filename ||= "ukraine-ato-#{Date.today}-#{x}x#{y}-#{delay}f"
  export_file_path = File.join dir, 'img', "#{filename}.gif"
  animation = ImageList.new()
  files = Dir[File.join images_dir, "*.jpg"].reject do |image_path|
    excludes.any? { |exclude| image_path =~ /#{exclude}\.jpg$/ }
  end
  last_file_name = files.last.match(/(\d{4}\-\d{2}\-\d{2}).jpg$/)[1]
  info_text = "#{last_file_name}\n@yuri_koval"
  files.each.with_index(1) do |image_path, index|
    full_image = Magick::Image::read(image_path).first
    # resize image
    timeline_height = [5, (y.to_f / 200).round].max
    resized_image = full_image.resize_to_fill(x, y).extent(x, y + timeline_height)
    full_image.destroy!

    # timeline
    progress_x = (x.to_f / files.size) * index
    timeline = Magick::Draw.new
    timeline.fill = 'black'
    timeline.rectangle 0, y, progress_x, y + timeline_height
    timeline.draw resized_image

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
    watermark.destroy!

    animation << resized_image
    puts "Processed #{image_path}"
  end

  puts "Writing to #{export_file_path}"
  animation.delay = delay
  animation.write(export_file_path)
  animation.destroy!
end
puts "DONE."
