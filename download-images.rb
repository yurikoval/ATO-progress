#!/usr/bin/env ruby
#
#
#
require 'open-uri'

dir = File.expand_path(File.dirname(__FILE__))
images_dir = File.join dir, 'img'
files = Dir[File.join images_dir, "*.jpg"]

start_date = Date.strptime(File.basename(files.last, '.*'), '%Y-%m-%d') + 1

(start_date..Date.today).to_a.each do |date|
  month = date.strftime('%m')
  day = date.strftime('%d')
  url = "http://mediarnbo.org/wp-content/uploads/#{date.year}/#{month}/#{day}-#{month}.jpg"
  save_file = File.join(images_dir, "#{date.strftime('%Y-%m-%d')}.jpg")
  if File.exist?(save_file)
    puts "Skipping #{url}"
    next
  end
  begin
    open(save_file, 'wb') do |file|
        file << open(url).read
    end
    puts "Saved #{url}"
  rescue OpenURI::HTTPError => e
    puts "#{e.message}: #{url}"
    File.delete save_file
  end
end





