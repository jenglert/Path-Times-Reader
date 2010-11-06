require 'path_schedule_reader'

schedules = PathScheduleReader.generate_schedules()

schedules.each{ |sch|

    puts sch.name.upcase + '(new String[] {"' + sch.stations.join('", "') + '"},new String[] {'
    puts sch.times.map { |time| 
      '"' + time[0] + '"'
      }.join(",")
      
    puts '}, new String[] {"' +  sch.travel_times.join('","') + '"}),'
  
  }