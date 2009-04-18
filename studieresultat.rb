#!/usr/bin/ruby

require 'rubygems'
require 'date'

class Course
  def initialize(code, name, points, grade, year, month)
    @code   = code
    @name   = name
    @points = points
    @grade  = grade
    @year   = year
    @month  = month
  end
  
  def code
    @code
  end

  def name
    @name
  end

  def points
    @points.to_f
  end

  def grade
    @grade
  end

  def year
    @year
  end
  
  def month
    @month
  end

  def real_grade
    @real_grade = @grade.to_i
    @real_grade if @real_grade > 0
  end
end

def school_year(courses, year_str)
  points = 0.0
  puts "=== #{year_str}"
  courses.each do |c|
    puts "#{c.code}: #{c.name}"
    points += c.points
  end
  puts "--- Totalt: #{points} hp\n\n"
end

inputfile = "studieresultat_input.txt"
f = File.open(inputfile)
courses = []
f.each do |line|
  if line =~ /(.+)[\*]*\t(.+)\t(\d{1,2}\.\d{1,2})\t(\w)\t(\d{4})-(\d{2})-(\d{2})/
    code    = $1
    name    = $2
    points  = $3
    grade   = $4
    year    = $5.to_i
    month   = $6.to_i
    day     = $7.to_i
    #puts "#{code} [#{name}] #{points} #{grade} #{year}-#{month}-#{day}"
    courses << Course.new(code, name, points, grade, year, month)
  end
end

first_year  = courses.select { |c| c.year == 2005 && c.month > 7 || c.year == 2006 && c.month < 6 }
second_year = courses.select { |c| c.year == 2006 && c.month > 7 || c.year == 2007 && c.month < 6 }
third_year  = courses.select { |c| c.year == 2007 && c.month > 7 || c.year == 2008 && c.month < 6 }
fourth_year = courses.select { |c| c.year == 2008 && c.month > 7 || c.year == 2009 && c.month < 6 }

school_year(first_year, "HT05/VT06")
school_year(second_year, "HT06/VT07")
school_year(third_year, "HT07/VT08")
school_year(fourth_year, "HT08/VT09")

real_grade_count = 0
real_grade_sum = 0.0
courses.each do |c|
  if c.real_grade
    real_grade_count += 1
    real_grade_sum += c.real_grade
    #puts "#{c.code} #{c.real_grade}"
  end
end
puts "Antal kurser: #{real_grade_count}"
puts "Summa: #{real_grade_sum}"
puts "Snitt: #{real_grade_sum/real_grade_count}"