require 'path_schedule_reader'

schedules = PathScheduleReader.generate_schedules()

schedules.each_with_index{ |sch, i|

    puts sch.name.upcase.sub("33RD", "TTRD") + '(new Station[] {' + sch.stations.join(', ') + '},new String[] {'
    puts sch.times.map { |time| 
      '"' + time[0] + '"'
      }.join(",")
      
    puts '}, new int[] {' +  sch.travel_times.join(',') + '},'
    
    if sch.name.upcase.include? "WEEKDAY"
      puts "ScheduleDay.Weekday"
    elsif sch.name.upcase.include? "SUN"
      puts "ScheduleDay.SundayHoliday"
    elsif sch.name.upcase.include? "SAT"
      puts "ScheduleDay.Saturday"
    end 
    
    if (i != schedules.count - 1)
      puts "),"
    else
      puts ");"
    end
  
  }