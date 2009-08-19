#!/usr/bin/ruby

require 'rubygems'
require 'date'
require 'hpricot'
require 'open-uri'

def mymerge(one, two)
	hash = {}
	one.each_with_index do |item,index|
		hash[item] = two[index]
	end
	return hash
end

class Course
  attr_reader :code, :name, :grade, :month, :day
  attr_accessor :year
  def initialize(code, name, points, grade, year, month, day)
    @code   = code
    @name   = name
    @points = points
    @grade  = grade
    @year   = year
    @month  = month
    @day    = day
    @level  = "unknown"
    @area   = "unknown"
    @url    = ""
  end
  
  def points
    @points.to_f
  end

  def real_grade
    @real_grade = @grade.to_i
    @real_grade if @real_grade > 0
  end
  
  def fetch_data
    @url = "http://kdb-5.liu.se/liu/lith/studiehandboken/svkursplan.lasso?&k_budget_year=#{@year}&k_kurskod=#{@code}"
    # fetch stuff
		doc = Hpricot(open(@url))
		titles = (doc./"span.txtkursivlista").map { |x| x = x.inner_text }
		content = (doc./"span.txtlista").map { |x| x = x.inner_text }
		$everything = mymerge(titles, content)
		data =  mymerge(titles, content)
		@level = data["Huvudomr\303\245de: "]
    @area = data["Utbildningsomr\303\245de: "]
  end
  
  def date
    return "#{@year}-#{@month}-#{@day}"
  end
  
  def excel_output
    return "#{@code};#{@name};#{@level};#{@points};#{@area};#{@grade};#{self.date};#{@url}\n"
  end
end

def school_year(courses, year_str)
  points = 0.0
  puts "=== #{year_str}"
  courses.each do |c|
    puts "#{c.code}: #{c.name} (#{c.points} hp)"
    points += c.points
  end
  puts "--- Totalt: #{points} hp\n\n"
end

inputfile = "studieresultat_input.txt"
f = File.open(inputfile)
courses = []
f.each do |line|
  if line =~ /(.+)[\*]*\t(.+)\t(\d{1,2}\.\d{1,2})\t(\w)\t(\d{4})-(\d{2})-(\d{2})/
    code    = $1.strip.delete("*")
    name    = $2
    points  = $3
    grade   = $4
    year    = $5.to_i
    month   = $6.to_i
    day     = $7.to_i
    courses << Course.new(code, name, points, grade, year, month, day)
  end
end

first_year  = courses.select { |c| c.year == 2005 && c.month >= 7 || c.year == 2006 && c.month <= 6 }
second_year = courses.select { |c| c.year == 2006 && c.month >= 7 || c.year == 2007 && c.month <= 6 }
third_year  = courses.select { |c| c.year == 2007 && c.month >= 7 || c.year == 2008 && c.month <= 6 }
fourth_year = courses.select { |c| c.year == 2008 && c.month >= 7 || c.year == 2009 && c.month <= 6 }

#school_year(first_year, "HT05/VT06")
#school_year(second_year, "HT06/VT07")
#school_year(third_year, "HT07/VT08")
#school_year(fourth_year, "HT08/VT09")

real_grade_count = 0
real_grade_sum = 0.0
points_tot = 0.0
File.open("klaradekurser.txt", "w") do |f|
  f.write("kurskod;namn;nivå;hp;huvudområde;betyg;datum;url\n")
  courses.each do |course|
    if course.real_grade
      real_grade_count += 1
      real_grade_sum += course.real_grade
    end
    points_tot += course.points
    if course.code.length == 6
      course.fetch_data
      f.write(course.excel_output)
      puts "Wrote #{course.code}"
    end
  end
end

#c = courses[26]
#c.fetch_data
#puts c.excel_output

#puts "Antal kurser: #{real_grade_count} (#{courses.length})"
#puts "Poäng totalt: #{points_tot}"
#puts "Snitt: #{real_grade_sum/real_grade_count}"