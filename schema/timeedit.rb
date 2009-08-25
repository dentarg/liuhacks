require 'open-uri'
require 'rubygems'
require 'icalendar'

include Icalendar

icsout = `echo ~/www/vhosts/d2b.zomg.se/tetest6.ics`.strip
icsin = "http://timeedit.liu.se/4DACTION/iCal_downloadReservations/timeedit.ics?from=803&to=813&id1=36522000&id2=28825002&id3=36344000&id4=36296000&id5=36285000&branch=5&lang=1"

def timeedit(icsurl)
  content = "" # raw content of ical feed will be loaded here
  open(icsurl) {|s| content = s.read }

  cals = Icalendar.parse(content)
  cal = cals.first

  newcal = Calendar.new
  newcal.custom_property("X-WR-CALNAME", "LiU")

  cal.events.each do |event|
      m = event.summary.match(/(\w+), (\S+),/).to_a
      kurskod = m[1]
      typ = m[2]
      plats = event.location
      if plats != nil
        if plats[-1].chr == "_"
          plats = event.location[0..-2] 
        end
      end
      if typ != nil
        if typ[0].chr == "F"
          typ = "FÖ"
        end
      end
      if typ != "LA"
        if typ != nil and plats != nil
          sum = "#{kurskod} #{typ} i #{plats}"
          newcal.event do
            dtstart(event.start)
            dtend(event.end)
            summary(sum)
            location(event.location)
          end
        end
      end
  end
  return newcal
end

cal = timeedit(icsin)
`/usr/bin/touch #{icsout}`
File.open(icsout, "w+").write(cal.to_ical)
