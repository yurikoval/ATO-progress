#!/usr/bin/env ruby

#  Generate scaled GIF images
#    by Yuri Kovalov
#    yuri@yurikoval.com
#    http://www.yurikoval.com

require "rubygems"
require "rmagick"
require "date"
include Magick

require 'bundler'
Bundler.require if defined?(Bundler)

class AtoGifGenerator
  def initialize(options = {})
    @original_x = options.fetch(:x, 800)
    @x = @original_x * 0.731 # Remove map legend
    @y = options.fetch(:y, 667)
    @frame_delay = options.fetch(:frame_delay, 50)
    @dir = options.fetch :dir, File.expand_path(File.dirname(__FILE__))
  end

  def save(save_path)
    animation = ImageList.new()
    last_file_name = files.last.match(/(\d{4}\-\d{2}\-\d{2}).jpg$/)[1]
    files.each.with_index(1) do |image_path, index|
      puts "[#{save_path}] processing #{image_path}"
      image = Magick::Image::read(image_path).first
      image = resize(image)
      image = add_timeline(image, index)
      image = add_note(image)
      animation << image
    end
    animation.delay = @frame_delay
    puts "Writing to #{save_path}"
    animation.write(save_path)
    animation.destroy!
    puts "Optimizing #{save_path}"
    image_optim.optimize_image! save_path
    true
  end

  private
    def files
      @files ||= Dir[File.join @dir, "*.jpg"].reject do |image_path|
        excluded_files.any? { |exclude| image_path =~ /#{exclude}\.jpg$/ }
      end
    end

    def resize(original_image)
      resized_image = original_image.resize_to_fill(@original_x, @y).extent(@x, @y + timeline_height)
      original_image.destroy!
      resized_image
    end

    def add_timeline(original_image, index)
      progress_x = (@x.to_f / files.size) * index
      timeline = Magick::Draw.new
      timeline.fill = 'black'
      timeline.rectangle 0, @y, progress_x, @y + timeline_height
      timeline.draw original_image
      original_image
    end

    def add_note(original_image)
      pointsize = (@y / 20).round
      watermark = Magick::Image.new(@x, @y + timeline_height) do
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
      original_image.composite!(watermark, SouthWestGravity, OverCompositeOp)
      watermark.destroy!
      original_image
    end

    def info_text
      last_file_name = files.last.match(/(\d{4}\-\d{2}\-\d{2}).jpg$/)[1]
      "#{last_file_name}\n@yuri_koval"
    end

    def excluded_files
      %w[2014-07-19]
    end

    def timeline_height
      [5, (@y.to_f / 200).round].max # have at least 5px for timeline
    end

    def image_optim
      @image_optim ||= ImageOptim.new(:pngout => false, :svgo => false, :nice => 5)
    end
end

dir = File.expand_path(File.dirname(__FILE__))
images_dir = File.join dir, 'img'

[
  [125, 104, 50, 'ukraine-ato-current-tiny'],
  [300, 250, 50, 'ukraine-ato-current-small'],
  [800, 667, 50, 'ukraine-ato-current'],
].each do |x, y, frame_delay, filename|
  export_file_path = File.join dir, 'img', "#{filename}.gif"
  image = AtoGifGenerator.new(dir: images_dir, x: x, y: y, frame_delay: frame_delay, filename: filename)
  image.save(export_file_path)
end
