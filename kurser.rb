require 'rubygems' 
require 'hpricot'
require 'open-uri'

#$url = "http://kdb-5.liu.se/liu/lith/studiehandboken/svkursplan.lasso?&k_budget_year=2007&k_kurskod="
$url = "http://kdb-5.liu.se/liu/lith/studiehandboken/svkursplan.lasso?&k_budget_year=2009&k_kurskod="

nya_kurser = %w(TDDC90 TSIT03 TDDB84 TDDD43 TSIN01 TDDD22 TDDC70)
oklarade_kurser = %w(TSRT12 TDDC94 TDDD19 TDDB44 TFYY68 TAMS27 TFYA48)
$kurser = oklarade_kurser

def mymerge(one, two)
	hash = {}
	one.each_with_index do |item,index|
		hash[item] = two[index]
	end
	return hash
end

class Course
	attr_reader :code, :name, :level, :area, :points
	def initialize(code)
		@code = code
		@name = Course.fetch_name(code)

    # fetch stuff
		doc = Hpricot(open($url + code))
		elements = doc.search("span.txtbold")
		@points = (elements/"b")[2].inner_text.strip[0..-4]
		titles = (doc./"span.txtkursivlista").map { |x| x = x.inner_text }
		content = (doc./"span.txtlista").map { |x| x = x.inner_text }
		$everything = mymerge(titles, content)

    @level = $everything["Huvudområde: "]
    @area = $everything["Utbildningsområde: "]
	end
	
	def self.fetch_name(course)
		doc = Hpricot(open($url + course))
		return doc.search("span.txtbold").at("b").inner_text.split(",")[0]
	end
	
	def pretty_print
	  return "#{@code};#{@name};#{@level};#{@points};#{@area}\n"
  end
end

File.open("kursdata.txt", "w") do |f|
  f.write("kurskod;namn;nivå;hp;huvudområde\n")
  $kurser.each do |kurs|
    f.write(Course.new(kurs).pretty_print)
    puts "Wrote #{kurs}"
  end
end