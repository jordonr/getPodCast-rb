require 'net/http'
require 'rexml/document'
require 'open-uri'
require 'fileutils'

#  getPodCast.rb
#  
#  Copyright 2013 jordonr <jordonr@dev-linux>
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  
#  

url = ARGV[0]
titles = []
enclosures = []
book_title = ''
book_link = ''
book_description = ''
book_category = []

# get the XML data as a string
begin
	xml_data = Net::HTTP.get_response(URI.parse(url)).body
rescue
	puts "URL is not valid"
	exit
end

# extract event information
doc = REXML::Document.new(xml_data)

doc.elements.each('rss/channel/title') do |ele|
   book_title << ele.text
end

doc.elements.each('rss/channel/link') do |ele|
   book_link << ele.text
end

doc.elements.each('rss/channel/description') do |ele|
   book_description << ele.text
end

doc.elements.each('rss/channel/category') do |ele|
   book_category << ele.text
end

#Create directory for download
if(!(File.directory?(book_title)))
	FileUtils.mkdir book_title
end

File.open("#{book_title}/info.txt", 'w') do |fh|
	fh << book_title + "\n\n" 
	fh << book_link + "\n"
	fh << book_category[0] + "\n\n"
	fh << book_description
end

#Title Elements
doc.elements.each('rss/channel/item/title') do |ele|
   titles << ele.text
end
#Get enclosure URLs
doc.elements.each('rss/channel/item/enclosure') do |ele|
   enclosures << ele.attributes['url']
end

# print all events
titles.each_with_index do |titles, idx|
	file_name = File.basename(enclosures[idx])
    print "#{titles} => #{enclosures[idx]} => #{file_name}\n"
    
    if(File.file?(file_name))
		print "#{file_name} exists!\n"
	else
		open(enclosures[idx]) do |mp3|
			File.open(book_title + '/' + file_name, 'w') do |fh|
				fh << mp3.read
			end
		end
		print "#{file_name} downloaded!\n"
	end
end
