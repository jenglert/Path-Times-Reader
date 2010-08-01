require 'path_schedule_reader'

schedules = PathScheduleReader.generate_schedules()

schedules.each{ |sch|

    puts sch.name + sch.stations.join("=>")
    sch.times.each { |time| 
      puts time.join " "
      
      }
  
  }