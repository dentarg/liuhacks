#!/usr/bin/env ruby

require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'
require 'tzinfo'
require 'ri_cal'


#icsfile = "/home/dentarg/www/vhosts/blog.dentarg.net/upplysningar.ics"
icsfile = "upplysningar.ics"
source = "http://www.lysator.liu.se/upplysning/upplysning.rss.html"
content = "" # raw content of rss feed will be loaded here
open(source) {|s| content = s.read }

rss = RSS::Parser.parse(content, false)

cal = RiCal.Calendar do |cal|

  #cal.custom_property("X-WR-CALNAME;VALUE=TEXT", "UppLYSning")
  #cal.custom_property("X-WR-CALDESC;VALUE=TEXT", "Lysators f�redragsverksamhet")
  cal.default_tzid="Europe/Stockholm"
  
  rss.items.each do |item|
  	if item.title.match(/(\d+)\/(\d+): (.+)/)
  		day = $1.to_i
  		month = $2.to_i
  		title = $3
  	end
  		
  	event_start = Time.utc(Time.now.year, month, day, 18)
  	event_end = Time.utc(Time.now.year, month, day, 20)
    
  	cal.event do |event|
  		event.description = item.description
  		event.dtstart = event_start
  		event.dtend = event_end
  		event.summary = title		
  		event.location = "Visionen, B-huset, Campus Valla, Linköping"
  		event.url = item.link
  	end
  end
end

File.open(icsfile, "w").write(cal.export)
