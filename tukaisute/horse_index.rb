require "csv"

def horse_index
  results = [["id"]]
  horse_ids = []
  
  race_result = CSV.table("today/2021/valid-padoc-train-data.csv", {:encoding => 'UTF-8', :converters => nil})
  race_result.each do |result|
    unless horse_ids.include? result[:horseid]
      horse_ids.push result[:horseid]
      results << [result[:horseid], result[:horsename]]
    end
  end
    
  CSV.open("intermediate/horse/horse_index_valid_padoc.csv", "w") do |csv| 
    results.each do |data|
      csv << data
    end
  end
end

horse_index()