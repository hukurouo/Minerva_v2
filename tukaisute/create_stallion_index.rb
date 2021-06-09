require "csv"

def create_stallion_index
  results = [["stallionId","stallionName"]]
  stallion_ids = []
  stallion_index = CSV.table("intermediate/stallion/horse_stallion_index.csv", {:encoding => 'UTF-8', :converters => nil})
  horse_2020 = CSV.table("intermediate/horse/horse_index_2020.csv", {:encoding => 'UTF-8', :converters => nil}).map{|csv|csv[:id]}

  stallion_index.each do |stallion|
    unless stallion_ids.include? stallion[:stallion_id]
      if horse_2020.include? stallion[:id]
        stallion_ids.push stallion[:stallion_id]
        results << [stallion[:stallion_id], stallion[:stallion_name]]
      end
    end
  end
  

  CSV.open("intermediate/stallion/stallion_index_2020.csv", "w") do |csv| 
    results.each do |data|
      csv << data
    end
  end
end

create_stallion_index()