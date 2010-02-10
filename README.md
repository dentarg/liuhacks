h2. tentasearch.rb

Ett litet verktyg som söker fram tentamensdatum för en eller flera kurser. Hämtar sin data från http://www4.student.liu.se/tentasearch/.

  $ tentasearch.rb TDDD19 TDDD25                                                 
  Kurskod	Kursnamn		Datum		Tid	Anmälningsperiod
  TDDD19	Avancerad programme...	2010-04-08	8-13	2010-03-09 - 2010-03-29
  TDDD19	Avancerad programme...	2010-05-31	14-19	2010-05-01 - 2010-05-23
  TDDD19	Avancerad programme...	2010-08-18	14-19	2010-07-19 - 2010-08-08
  TDDD25	Distribuerade syste...	2010-03-10	8-12	2010-02-08 - 2010-02-28
  TDDD25	Distribuerade syste...	2010-06-08	8-12	2010-05-09 - 2010-05-30
  TDDD25	Distribuerade syste...	2010-08-20	8-12	2010-07-21 - 2010-08-10

För att skapa en fil att importera i sin kalender:

  $ tentasearch.rb --ical TDDD19 TDDD25 > exams.ics

h2. upplys.rb

Läser [RSS-feeden](http://www.lysator.liu.se/upplysning/upplysning.rss.html) för Lysators föredragsverksamhet [UppLYSning](http://www.lysator.liu.se/upplysning/) och producerar en iCal-feed.
