#!/usr/bin/ruby

require 'rubygems'
require 'icalendar'
require 'date'

include Icalendar

def usage
  puts "Usage: #{$0} inputfile"
  puts "inputfile är en textfil med utdrag från Tentamensanmälan i Studentportalen"
  puts "skapar kalenderfilen inputfile.ics"
end

if !ARGV.empty? && ARGV.length == 1
  inputfile = ARGV[0]
  if !File.exist?(inputfile)
    puts "File not found: #{inputfile}"
    exit
  end
else
  usage
  exit
end

cal = Calendar.new
cal.custom_property("X-WR-CALNAME", "Tentor")
cal.custom_property("X-WR-CALDESC", "Examinationsmoment")

f = File.open(inputfile)

f.each do |line|
  if line =~ /(\w+)\t(.+)\t(.+)\t(\d{4})-(\d{2})-(\d{2})\t (\d{1,2})\t-\t(\d{2})/
    code = $1
    name = $2[0..-3]
    type = $3
    year = $4.to_i
    month = $5.to_i
    day = $6.to_i
    starttime = $7.to_i
    endtime = $8.to_i
    #puts "#{code} [#{name}] #{year}-#{month}-#{day} #{starttime}-#{endtime}"
    puts "#{code}: #{year}-#{month}-#{day} #{starttime}-#{endtime}"
  end

  event_start = DateTime.civil(Time.now.year, month, day, starttime)
  event_end = DateTime.civil(Time.now.year, month, day, endtime)

  cal.event do
    dtstart(event_start)
    dtend(event_end)
    summary("#{code} #{name}")
    description(type)
    klass("PUBLIC")
  end
end

icsfile = "#{inputfile}.ics"
File.open(icsfile, "w").write(cal.to_ical)
puts "Wrote to above data to #{icsfile}."