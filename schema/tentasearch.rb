require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'
require 'rubygems'
require 'icalendar'
require 'date'

include Icalendar

#icsfile = `echo ~/www/vhosts/d2b.zomg.se/tetest2.ics`.strip
source = "http://www4.student.liu.se/tentasearch?kurskod=TDDB56"
content = "" # raw content of ical feed will be loaded here
open(source) {|s| content = s.read }


# datum
content.scan(/(\d+)&#45;(\d+)&#45;(\d+)/)
# kurs
content.scan(/(\w+\/\w+)/)

#cals = Icalendar.parse(content)
#cal = cals.first

#newcal = Calendar.new
#newcal.custom_property("X-WR-CALNAME", "LiU")

=begin
cal.events.each do |event|
    m = event.summary.match(/(\w+), (\S+),/).to_a
    kurskod = m[1]
    typ = m[2]
    plats = event.location
    plats = event.location[0..-2] if plats[-1].chr == "_"
    if typ != "LA"
      sum = "#{kurskod} #{typ} i #{plats}"
      newcal.event do
        dtstart(event.start)
        dtend(event.end)
        summary(sum)
        location(event.location)
      end
    end
end
=end
=begin
liu.items.each do |item|
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
=end

#`/usr/bin/touch #{icsfile}`
#File.open(icsfile, "w+").write(newcal.to_ical)
