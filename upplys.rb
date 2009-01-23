#!/usr/local/bin/ruby

require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'
require 'rubygems'
require 'icalendar'
require 'date'

include Icalendar

icsfile = "/home/dentarg/www/vhosts/blog.dentarg.net/upplysningar.ics"
source = "http://www.lysator.liu.se/upplysning/upplysning.rss.html"
content = "" # raw content of rss feed will be loaded here
open(source) {|s| content = s.read }

rss = RSS::Parser.parse(content, false)
cal = Calendar.new

cal.custom_property("X-WR-CALNAME", "UppLYSning")
cal.custom_property("X-WR-CALDESC", "Lysators föredragsverksamhet")

rss.items.each do |item|
	if item.title.match(/(\d+)\/(\d+): (.+)/)
		day = $1.to_i
		month = $2.to_i
		title = $3
	end
		
	event_start = DateTime.civil(Time.now.year, month, day, 18)
	event_end = DateTime.civil(Time.now.year, month, day, 20)

	cal.event do
		dtstart(event_start)
		dtend(event_end)
		summary(title)
		description(item.description)
		klass("PUBLIC")
		url(item.link)
	end
end

File.open(icsfile, "w").write(cal.to_ical)
