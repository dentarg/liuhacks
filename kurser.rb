require 'rubygems' 
require 'hpricot'
require 'open-uri'

#$url = "http://kdb-5.liu.se/liu/lith/studiehandboken/svkursplan.lasso?&k_budget_year=2007&k_kurskod="
$url = "http://kdb-5.liu.se/liu/lith/studiehandboken/svkursplan.lasso?&k_budget_year=2009&k_kurskod="

$kurser = %w(TGTU55 TAMS27 TDDC93 TSEA29 TDDB68)

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
	  puts "#{@code}: #{@name}"
	  puts "\t Level: #{@level}"
	  puts "\t Area: #{@area}"
	  puts "\t Points: #{@points} hp"
	  puts "---"
  end
end

$kurser.each do |kurs|
  Course.new(kurs).pretty_print
end