require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'path_schedule'


PATH_TRAIN_FILES = ["NWK_WTC_Weekday.html",
"NWK_WTC_Sat.html",
"NWK_WTC_Sun_Hol.html",
"WTC_NWK_Weekday.html",
"WTC_NWK_Sat.html",
"WTC_NWK_Sun_Hol.html",
"HOB_WTC_Weekday.html",
"WTC_HOB_Weekday.html",
"JSQ_33rd_Weekday.html",
"33rd_JSQ_Weekday.html",
"HOB_33rd_Weekday.html",
"JSQ_33rd_via_HOB_Sat.html",
"JSQ_33rd_via_HOB_Sun_Hol.html",
"33rd_HOB_Weekday.html",
"33rd_JSQ_via_HOB_Sat.html",
"33rd_JSQ_via_HOB_Sun_Hol.html",
"JSQ_33rd_Weekday.html",
"JSQ_33rd_via_HOB_Sat.html",
"JSQ_33rd_via_HOB_Sun_Hol.html",
"33rd_JSQ_Weekday.html",
"33rd_JSQ_via_HOB_Sat.html",
"33rd_JSQ_via_HOB_Sun_Hol.html"]


for pathTrainFile in PATH_TRAIN_FILES do
  puts "Processing :" + pathTrainFile
  
  schedule = PathSchedule.new();
  schedule.name = pathTrainFile.sub(".html", "")
  
  doc = Nokogiri::HTML(open('http://www.panynj.gov/path/' + pathTrainFile))
  
  puts "Downloaded file successfully"
  
  # Parse the station names
  stations = []
  doc.xpath('//table[@class="pathTable"]/tbody/tr[3]/th/span').each do |span|
    stations << span.content
  end
  schedule.stations = stations
  
  # Parse the times
  times = []
  row_count = doc.xpath('//table[@class="pathTable"]/tbody/tr').count
  
  for i in 3..row_count do
    puts i
    
    column_count = doc.xpath('//table[@class="pathTable"]/tbody/tr[' + i + ']/td/span').count
    
    if column_count == 1 then
      
    else
      doc.xpath('//table[@class="pathTable"]/tbody/tr[' + i + ']/td/span').each do |span|
        puts span.content
      end
    end
    
  end
    
    
  
end