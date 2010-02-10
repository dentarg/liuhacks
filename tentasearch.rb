#!/usr/bin/env ruby
require 'rubygems' 
require 'hpricot'
require 'open-uri'
require 'icalendar'
require 'date'
include Icalendar

COURSE_CODE_REGEXP = /[A-Z]{4}\d{2}/

# TODO: Use OOP

# Wrapper around http://www4.student.liu.se/tentasearch/

# ./tentasearch TDDD25 TDDD41
# Kurskod Kursnamn              Datum       Tid     Anmälningsperiod
# TDDD25  Distribuerade system  2010-03-10  8-12    2010-02-08 - 2010-02-28
# TDDD41	Data Mining - ...  	  2010-03-12  14-18   2010-02-10 - 2010-03-02

# ./tentasearch --ical TDTS02
# Output: iCal data

def test_regex(line,regexps)
  for re in regexps
    if re.match(line)
      #p line[0..80] + "..."
      #puts "#{re.to_s}: "
      p line.match(re).to_a[1..-1]
    end
  end
end

def search(codes)
  results = []
  if not codes.empty?
    codes.each do |code|
      tentasearch(code, results)
    end
  end
  return results
end

def tentasearch(code, results)
  # fetch stuff
  url = "http://www4.student.liu.se/tentasearch/?kurskod=#{code}"
  doc = Hpricot(open(url))
  doc.to_s.each do |line|
    parse_html(line, results)
  end
end

def parse_html(line, results)
  # This is a complete line
  # <td><font size="2" face="Verdana, Arial, Helvetica, sans-serif">TDDD25/TEN1</font></td>
  # FIXME: Should compare with given course code here
  re_code = /<td><font size="2" face="Verdana, Arial, Helvetica, sans-serif">(#{COURSE_CODE_REGEXP})\/(\w{4})<\/font><\/td>/
  # <td><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><i>Distribuerade system &nbsp;</i></font></td>
  re_name = /<td><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><i>(.+) .+<\/i><\/font><\/td>/
  # <td><font size="2" face="Verdana, Arial, Helvetica, sans-serif">2010&#45;03&#45;10</font></td>
  re_date = /<td><font size="2" face="Verdana, Arial, Helvetica, sans-serif">(\d{4})&#45;(\d{2})&#45;(\d{2})<\/font><\/td>/
  # <td align="right"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;8</font></td>
  re_starttime = /<td align="right"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;(\d{1,2})<\/font><\/td>/
  # <td><font size="2" face="Verdana, Arial, Helvetica, sans-serif">&#45;</font></td>
  # <td><font size="2" face="Verdana, Arial, Helvetica, sans-serif">12</font></td>
  re_endtime = /<td><font size="2" face="Verdana, Arial, Helvetica, sans-serif">(\d{2})<\/font><\/td>/
  # <td><font size="2" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;Linköping</font></td>
  # <td nowrap><font size="2" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;2010&#45;02&#45;08&nbsp;&#45;&nbsp;2010&#45;02&#45;28</font></td></tr>
  re_signupperiod = /<td nowrap><font size="2" face="Verdana, Arial, Helvetica, sans-serif">&nbsp;(\d{4})&#45;(\d{2})&#45;(\d{2})&nbsp;&#45;&nbsp;(\d{4})&#45;(\d{2})&#45;(\d{2})<\/font><\/td><\/tr>/

  regexps = [re_code, re_name, re_date, re_starttime, re_endtime, re_signupperiod]
  #test_regex(line, regexps)
  
  res = { :code         =>  line.match(re_code).to_a[1], 
          :name         =>  line.match(re_name).to_a[1], 
          :date         =>  "#{line.match(re_date).to_a[1]}" +
                            "-#{line.match(re_date).to_a[2]}-" +
                            "#{line.match(re_date).to_a[3]}",
          :year         =>  line.match(re_date).to_a[1].to_i,
          :month        =>  line.match(re_date).to_a[2].to_i,
          :day          =>  line.match(re_date).to_a[3].to_i,
          :starttime    =>  line.match(re_starttime).to_a[1].to_i,
          :endtime      =>  line.match(re_endtime).to_a[1].to_i,
          :signupstart  =>  "#{line.match(re_signupperiod).to_a[1]}-" +
                            "#{line.match(re_signupperiod).to_a[2]}-" + 
                            "#{line.match(re_signupperiod).to_a[3]}",
          :signupend    =>  "#{line.match(re_signupperiod).to_a[4]}-" +
                            "#{line.match(re_signupperiod).to_a[5]}-" + 
                            "#{line.match(re_signupperiod).to_a[6]}" }

  # FIXME: Should check if everything matched
  if re_name.match(line)
    results << res
  end
end

def print_help()
  puts "Usage: #{$0} [option] coursecode ..."
  puts "  -i, --ical\tOutput iCal data"
  puts "  -h, --help\tThis help text"
  puts ""
  puts "Examaple:"
  puts "  #{$0} TDDD19 TDDD25"
  puts "  #{$0} -i TDDD19 TDDD25"
end

def print_ical(codes)
  results = search(codes)
  cal = Calendar.new
  cal.custom_property("X-WR-CALNAME;VALUE=TEXT", "#{codes}")
  cal.custom_property("X-WR-CALDESC;VALUE=TEXT", "Exams: #{codes}")
  for res in results
    event = Event.new
    event.summary = "#{res[:code]} #{res[:name]}"
    event.start = DateTime.civil(res[:year], res[:month], res[:day], res[:starttime])
    event.end = DateTime.civil(res[:year], res[:month], res[:day], res[:endtime])
    cal.add_event(event)
  end
  puts cal.to_ical
end

def print_list(codes)
  results = search(codes)
  puts "Kurskod\tKursnamn\t\tDatum\t\tTid\tAnmälningsperiod"
  for res in results
    len = res[:name].length
    if len > 18
      name = "#{res[:name][0..18]}..."
    else
      name = res[:name]
      (18-len).times do 
         name = name + " "
       end
    end
    puts "#{res[:code]}\t#{name}\t#{res[:date]}\t#{res[:starttime]}-" +
      "#{res[:endtime]}\t#{res[:signupstart]} - #{res[:signupend]}"
  end
end

def start(argv)
  if argv.empty? or argv[0] == "-h" or argv[0] == "--help"
    print_help
  elsif argv[0] == "-i" or argv[0] == "--ical"
    codes = argv[1..-1]
    codes.collect! { |code| code.match(COURSE_CODE_REGEXP) }
    print_ical(codes)
  else
    codes = argv[0..-1]
    codes.collect! { |code| code.match(COURSE_CODE_REGEXP) }
    print_list(codes)
  end
end

start ARGV