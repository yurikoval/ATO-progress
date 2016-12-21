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
    attr_reader :date, :save_file
    def initialize(date, save_file)
      @date      = date
      @save_file = save_file
    end

    def download
      url = generate_url(date)
      begin
        open(save_file, 'wb') do |file|
          file << open(url).read
        end
        image_optim.optimize_image! save_file
        puts "Saved #{url}"
      rescue OpenURI::HTTPError => e
        puts "#{e.message}: #{url}"
        File.delete save_file
      end
    end

  private

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
