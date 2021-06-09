require "csv"

def horse_index
  results = [["id","name"]]
  horse_ids = []
  (2020..2020).each do |year|
    year = year.to_s
    (1..10).each do |i|
      place =  format("%02<number>d", number: i)
      race_result = CSV.table("datas/#{year}/#{place}/race_result.csv", {:encoding => 'UTF-8', :converters => nil})

      race_result.each do |result|
        unless horse_ids.include? result[:horseid]
          horse_ids.push result[:horseid]
          results << [result[:horseid], result[:horsename]]
        end
      end
    end
    p year
  end
  CSV.open("intermediate/horse/horse_index_2020.csv", "w") do |csv| 
    results.each do |data|
      csv << data
    end
  end
end

horse_index()