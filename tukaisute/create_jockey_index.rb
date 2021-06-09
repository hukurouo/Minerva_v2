require "csv"

def create_jockey_index
  results = [["jockeyId","JockeyName"]]
  jockey_ids = []
  (1..10).each do |i|
    place =  format("%02<number>d", number: i)
    race_result = CSV.table("datas/2020/#{place}/race_result.csv", {:encoding => 'UTF-8', :converters => nil})
    
    race_result.each do |result|
      unless jockey_ids.include? result[:jockeyid]
        jockey_ids.push result[:jockeyid]
        results << [result[:jockeyid], result[:jockeyname]]
      end
    end
    p "done" + i.to_s
  end

  CSV.open("intermediate/jockey/jockey_index_2020.csv", "w") do |csv| 
    results.each do |data|
      csv << data
    end
  end
end

create_jockey_index()