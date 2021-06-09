require "csv"

def create_trainer_index
  results = [["trainerId"]]
  trainer_ids = []
  (1..10).each do |i|
    place =  format("%02<number>d", number: i)
    race_result = CSV.table("datas/2020/#{place}/race_result.csv", {:encoding => 'UTF-8', :converters => nil})
    
    race_result.each do |result|
      unless trainer_ids.include? result[:trainerid]
        trainer_ids.push result[:trainerid]
        results << [result[:trainerid]]
      end
    end
    p "done" + i.to_s
  end

  CSV.open("intermediate/trainer/trainer_index_2020.csv", "w") do |csv| 
    results.each do |data|
      csv << data
    end
  end
end

create_trainer_index()