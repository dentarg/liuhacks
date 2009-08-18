require 'rubygems' 
require 'hpricot'
require 'open-uri'

#$url = "http://kdb-5.liu.se/liu/lith/studiehandboken/svkursplan.lasso?&k_budget_year=2007&k_kurskod="
$url = "http://kdb-5.liu.se/liu/lith/studiehandboken/svkursplan.lasso?&k_budget_year=2009&k_kurskod="

$kurser = %w(TGTU55 TAMS27 TDDC93 TSEA29 TDDB68 TSDT13)

class Course
	attr_reader :code, :name
	def initialize(code)
		@code = code
		@name = Course.fetch_name(code)
		@txtlista = Course.txtlista(code)
	end

	def self.merge(one, two)
		hash = {}
		one.each_with_index do |item,index| 
			hash[item] = two[index]
		end
		return hash
	end
	
	def self.bamse_funktion(code)
		doc = Hpricot(open($url + code))
		titles = (doc./"span.txtkursivlista").map { |x| x = x.inner_text }
		#p titles
		content = (doc./"span.txtlista").map { |x| x = x.inner_text }
		#p content
		$everything = self.merge(titles, content)
		#p $everything
		puts $everything["Kurslitteratur: "]
		puts $everything["Huvudområde: "]
		
	end
	
	def self.fetch_info(course)
		doc = Hpricot(open($url + course))
		(doc/"span.txtbold").each do |element|
			puts element.inner_html
		end
	end
	
	def self.txtlista(course)
		doc = Hpricot(open($url + course))
		(doc/"span.txtlista").each do |element|
			p element.inner_html
			puts ""
		end
	end
	
	def self.fetch_name(course)
		doc = Hpricot(open($url + course))
		return doc.search("span.txtbold").at("b").inner_text.split(",")[0]
	end
end

#$kurser.each {|kurs| get_course_name(kurs)}

#bla = Course.new("TAMS27")
#p bla.name

#Course.bamse_funktion("TAMS27")
Course.bamse_funktion("TDDC90")