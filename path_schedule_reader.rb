require 'rubygems'
require 'nokogiri'
require 'path_schedule'

require 'active_support' 

PATH_TRAIN_FILES = [
"NWK_WTC_Weekday.html",
"NWK_WTC_Sat.html",
"NWK_WTC_Sun_Hol.html",
"WTC_NWK_Weekday.html",
"WTC_NWK_Sat.html",
"WTC_NWK_Sun_Hol.html",
"HOB_WTC_Weekday.html",
"WTC_HOB_Weekday.html",
"HOB_33rd_Weekday.html",
"JSQ_33rd_Weekday.html",
"JSQ_33rd_via_HOB_Sat.html",
"JSQ_33rd_via_HOB_Sun_Hol.html",
"33rd_JSQ_Weekday.html",
"33rd_HOB_Weekday.html",
"33rd_JSQ_Weekday.html",
"33rd_JSQ_via_HOB_Sat.html",
"33rd_JSQ_via_HOB_Sun_Hol.html"]

class PathScheduleReader

  def self.generate_schedules 
    
    schedules = []

    for pathTrainFile in PATH_TRAIN_FILES do
      schedule = PathSchedule.new();
      schedule.name = pathTrainFile.sub(".html", "")
  
      doc = Nokogiri::HTML(open('schedules/' + pathTrainFile))
  
      # Parse the station names
      stations = []
      doc.xpath('//table[@class="pathTable"]/tbody/tr[3]/th/span').each do |span|
        stations << span.content.strip
      end
      schedule.stations = stations
  
      # Parse the times
      all_times = []
      row_count = doc.xpath('//table[@class="pathTable"]/tbody/tr').count
  
      # Iterate over each time row.  There are also "repeating" rows so we need to handle those
      for i in 3..row_count do
        column_count = doc.xpath('//table[@class="pathTable"]/tbody/tr[' + i.to_s + ']/td').count
        
        times = []
    
        if column_count == 1 then # handle repeat row
          repeat_rows = doc.xpath('//table[@class="pathTable"]/tbody/tr[' + i.to_s + ']/td/div/span[@class="style15"]') +
            doc.xpath('//table[@class="pathTable"]/tbody/tr[' + i.to_s + ']/td/div/span/span[@class="style15"]');
          
          repeat_rows.each do |span|
            repeat = span.content
        
            repeat_interval = repeat.match(/Every (\d\d?).*/i)[1].strip
            end_time = Time.parse(repeat.match('.*(..:.. ..).*')[1].strip)
            
            # Get the previous starting time
            current_time_string = all_times[all_times.count() - 1][0] 
            current_time = Time.parse(current_time_string)
            
            # Determine if the current time plus the next interval is before the end time.
            while (current_time + Integer(repeat_interval) * 60) < end_time
              current_time = current_time + Integer(repeat_interval) * 60
              current_time_string = current_time.strftime '%I:%M %p'
              
              new_time_to_add = []
              all_times[all_times.count() - 1].each do |prev_time_string| 
                prev_time = Time.parse(prev_time_string)
                prev_time = prev_time + Integer(repeat_interval) * 60
                new_time_to_add <<  prev_time.strftime('%I:%M %p')
              end
              
              all_times << new_time_to_add
              
            end # End while current_time_string != end_time
            
          end
        else # Handle non-repeat row
          # Handle AM
          doc.xpath('//table[@class="pathTable"]/tbody/tr[' + i.to_s + ']/td/span[@class="style2"]').each do |span|
            times << Time.parse(span.content).strftime('%I:%M') + " AM"
          end
          
          # Handle PM
          doc.xpath('//table[@class="pathTable"]/tbody/tr[' + i.to_s + ']/td/span[@class="style9"]').each do |span|
            times << Time.parse(span.content).strftime('%I:%M') + " PM"
          end
          
          # Add the list of times to the overall list
          if times.count() > 0 then
            all_times << times
            
            if !schedule.travel_times then
              schedule.travel_times = []
              
              
              0.upto(times.count() - 2).each{ |i|
                schedule.travel_times << (Time.parse(times[i+1]) - Time.parse(times[i])) / 60
              }
            end
             
          end
        end
        schedule.times = all_times
      end
      schedules << schedule
    end # End loop over each file
    return schedules
  end

end