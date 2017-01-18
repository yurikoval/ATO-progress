#!/usr/bin/env ruby
#
#
#
require 'bundler'
if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end
require 'open-uri'

class Downloader
  CURRENT_DIR = File.expand_path(File.dirname(__FILE__))
  IMAGES_DIR  = File.join(CURRENT_DIR, 'img')

  class ImageDownloader
    class DownloadError < StandardError; end
    attr_reader :date, :save_file
    def initialize(date, save_file)
      @date      = date
      @save_file = save_file
    end

    def download
      if image = get_image
        open(save_file, 'wb') { |f| f << image }
        image_optim.optimize_image! save_file
      end
    end

  private

    def get_image
      [nil, 1, 2, 3].each do |attempt|
        url = generate_url(date, attempt)
        puts "Downloading #{url}"
        image = open(url).read
        puts "#{url}, #{image.size}"
        return image if image.size.between?(900000, 1200000)
      end
      raise DownloadError, "No suitable image found"
    rescue OpenURI::HTTPError => e
      puts e.message
    end

    def generate_url(d, increment = nil)
      month = d.strftime('%m')
      day = d.strftime('%d')
      if increment.nil?
        "http://mediarnbo.org/wp-content/uploads/#{d.year}/#{month}/#{day}-#{month}.jpg"
      else
        "http://mediarnbo.org/wp-content/uploads/#{d.year}/#{month}/#{day}-#{month}-#{increment}.jpg"
      end
    end

    def image_optim
      ImageOptim.new(:pngout => false, :svgo => false, :nice => 5)
    end
  end

  def download
    (start_date..Date.today).to_a.each do |date|
      file_name = "#{date.strftime('%Y-%m-%d')}.jpg"
      save_file = File.join(IMAGES_DIR, file_name)
      if File.exist?(save_file)
        puts "Skipping #{file_name}"
        next
      end
      ImageDownloader.new(date, save_file).download
    end
  end

private

  def images
    Dir[File.join IMAGES_DIR, "*.jpg"]
  end

  def start_date
    Date.strptime(File.basename(images.last, '.*'), '%Y-%m-%d') + 1
  end
end

Downloader.new.download
