require 'rubygems' 
require 'hpricot'
require 'open-uri'

COURSE_CODE_REGEXP = /[A-Z]{4}\d{2}/

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
      puts "#{re.to_s}: "
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
  #doc = Hpricot(open(url))
  doc = Hpricot(open("TDDD19_hpricot.html")) # for faster testing
  doc.to_s.each do |line|
    parse_html(line, results)
  end
end

def parse_html(line, results)
  # Looking for this:
  # <td><font size="2" face="Verdana, Arial, Helvetica, sans-serif">TDDD25/TEN1</font></td>
  # FIXME: Should compare with given course code here
  re_code = /<td><font size="2" face="Verdana, Arial, Helvetica, sans-serif">(#{COURSE_CODE_REGEXP})\/([A-Z]{3}\d)<\/font><\/td>/
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
    
  code = line.match(re_code).to_a[1]
  name = line.match(re_name).to_a[1]
  date = "#{line.match(re_date).to_a[1]}-#{line.match(re_date).to_a[2]}-#{line.match(re_date).to_a[3]}"
  starttime = line.match(re_starttime).to_a[1]
  endtime = line.match(re_endtime).to_a[1]
  signupstart = "#{line.match(re_signupperiod).to_a[1]}-#{line.match(re_signupperiod).to_a[2]}-#{line.match(re_signupperiod).to_a[3]}"
  signupend = "#{line.match(re_signupperiod).to_a[4]}-#{line.match(re_signupperiod).to_a[5]}-#{line.match(re_signupperiod).to_a[6]}"
  
  res = {:code => code, 
          :name => name, 
          :date => date,
          :startime => starttime,
          :endtime => endtime,
          :signupstart => signupstart, 
          :signupend => signupend }
  if re_name.match(line)
    results << res
  end
end

def print_help()
  puts "Help!"
end

def print_ical(codes)
  results = search(codes)
end

def print_list(codes)
  results = search(codes)
  puts "Kurskod\tKursnamn\t\tDatum\t\tTid\tAnmälningsperiod"
  for res in results
    if res[:name].length > 18
      name = "#{res[:name][0..18]}..."
    else
      name = res[:name]
    end
    # {:code=>"TDDD25", :date=>"2010-10-10", :startime=>"8", :signupstart=>"2010-08-08", :name=>"Distribuerade system", :signupend=>"2010-02-28"}
    puts "#{res[:code]}\t#{name}\t#{res[:date]}\t#{res[:startime]}-#{res[:endtime]}\t#{res[:signupstart]} - #{res[:signupend]}"
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