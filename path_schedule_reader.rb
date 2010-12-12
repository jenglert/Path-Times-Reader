require 'rubygems'
require 'nokogiri'
require 'path_schedule'

require 'active_support' 

PATH_TRAIN_FILES = [
  "33rd_HOB_Sat.html",
  "33rd_HOB_Sun_Hol.html",
  '33rd_HOB_Weekday.html',
  '33rd_JSQ_Sat.html',
  '33rd_JSQ_Sun_Hol.html',
  '33rd_JSQ_via_HOB_Sat.html',
  '33rd_JSQ_via_HOB_Sun_Hol.html',
  '33rd_JSQ_via_HOB_Weekday.html',
  '33rd_JSQ_Weekday.html',
  'HOB_33rd_Sat.html',
  'HOB_33rd_Sun_Hol.html',
  'HOB_33rd_Weekday.html',
  'HOB_WTC_Weekday.html',
  'JSQ_33rd_via_HOB_Sat.html',
  'JSQ_33rd_via_HOB_Sun_Hol.html',
  'JSQ_33rd_Weekday.html',
  'NWK_WTC_Sat.html',
  'NWK_WTC_Sun_Hol.html',
  'NWK_WTC_Weekday.html',
  'WTC_HOB_Weekday.html',
  'WTC_NWK_Sat.html', 
  'WTC_NWK_Sun_Hol.html',
  'WTC_NWK_Weekday.html']

class PathScheduleReader

  def self.generate_schedules 
    
    schedules = []

    for pathTrainFile in PATH_TRAIN_FILES do
      schedule = PathSchedule.new();
      schedule.name = pathTrainFile.sub(".html", "")
  
      doc = Nokogiri::HTML(open('schedules/' + pathTrainFile))
  
      # Parse the station names
      header_rows = doc.xpath('//table/thead/tr').count
      doc.xpath("//table/thead/tr[#{header_rows}]/th").each do |span|
        schedule.stations << convert_station_name(span.content.strip, schedule.name) if !(['Arrive', 'Depart'].include? span.content.strip)
      end
  
      # Parse the times
      all_times = []
      row_count = doc.xpath('//table/tbody/tr').count
  
      # Iterate over each time row.  There are also "repeating" rows so we need to handle those
      for i in 0..row_count do
        
        # Process any misplaced station names here
        if doc.xpath("//table/tbody/tr[#{i.to_s}]/td").map{ |node|  node.content.strip }.none? { |td| td.include? ":"}
          doc.xpath("//table/tbody/tr[#{i.to_s}]/th").each do |td|
            schedule.stations << convert_station_name(td.content.strip, schedule.name) if !(td.content.strip.include? "operate")
          end
          
          next
        end
        
        column_count = [doc.xpath("//table/tbody/tr[#{i.to_s}]/td").count,
                        doc.xpath("//table/tbody/tr[#{i.to_s}]/th").count].max
        
        times = []
    
        if column_count == 1 then # handle repeat row
          # There are no repeat rows.!
          
        else # Handle non-repeat row
          # Handle AM
          doc.xpath('//table/tbody/tr[' + i.to_s + ']/td').each do |span|
            if span.inner_html.upcase.include?("STRONG") or
              span.inner_html.upcase.include?("STYLE9") or
              (span.attribute("class") and span.attribute("class").content.upcase.include?("STYLE9")) or
              (span.parent.attribute("class") and span.parent.attribute("class").content.upcase.include?("STYLE9"))
              times << Time.parse(span.content).strftime('%I:%M') + " PM"
            else
              times << Time.parse(span.content).strftime('%I:%M') + " AM"
            end
          end
          
          # Add the list of times to the overall list
          if times.count() > 0 then
            all_times << times
            
            if !schedule.travel_times then
              schedule.travel_times = []
              
              
              0.upto(times.count() - 2).each{ |i|
                schedule.travel_times << ((Time.parse(times[i+1]) - Time.parse(times[i])) / 60).to_i
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
  
  def self.convert_station_name(name, schedule)
    if name ==  "WTC"
      return "Station.WTC"
    elsif name == "Hoboken"
      return "Station.Hoboken"
    elsif name == "33rd St."
      return "Station.ThirtyThird"
    elsif name == "23rd St."
      return "Station.TwentyThird"
    elsif name == "14th St."
      return "Station.Fourteenth"
    elsif name == "9th St."
      return "Station.Nineth"
    elsif name == "Chris. St."
      return "Station.Christopher"
    elsif name == "Newport"
      return "Station.Pavonia"
    elsif name == "Exchange Pl."
      return "Station.ExchangePlace"
    elsif name == "Grove St."
      return "Station.GroveSt"
    elsif name == "JSQ"
      return "Station.JournalSquare"
    elsif name == "Harrison"
      return "Station.Harrison"
    elsif name == "Newark"
      return "Station.Newark"
    elsif !name.blank?
      raise "Station '#{name}' was not found in schedule '#{schedule}'"
    end
    
    return ''
  end

end