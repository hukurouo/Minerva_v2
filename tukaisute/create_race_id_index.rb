require "csv"

def create_race_index
  results = [["raceId"]]
  race_ids = []
 
  race_result = CSV.table("today/2021/valid-padoc-train-data-add.csv", {:encoding => 'UTF-8', :converters => nil})
    
  race_result.each do |result|
    unless race_ids.include? result[:id]
      race_ids.push result[:id]
      results << [result[:id]]
    end
  end

  CSV.open("today/2021/valid-padoc-race-index.csv", "w") do |csv| 
    results.each do |data|
      csv << data
    end
  end
end

create_race_index()