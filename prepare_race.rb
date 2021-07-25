require "csv"

def prepare_race
  place_map = {} 
  place_index = CSV.table("race_info.csv", {:encoding => 'UTF-8', :converters => nil})
  place_index.each do |place_index|
    place_map[place_index[:id]] = place_index[:place]
  end
  stallion_index = CSV.table("intermediate/stallion/stallion_index_2020.csv", {:encoding => 'UTF-8', :converters => nil})
  stallion_index.each_with_index do |stallion, index|
    stallion_map = {}
    horse_list = []
    horse_stallion_index = CSV.table("intermediatestallion/horse_stallion_index.csv", {:encoding => 'UTF-8', :converters => nil})
    horse_stallion_index.each do |h|
      if h[:stallion_id] == stallion[:stallionid]
        horse_list << h[:id]
      end
    end
    (2017..2019).each do |year|
      year = year.to_s
      (1..10).each do |i|
        place =  format("%02<number>d", number: i)
        race_result = CSV.table("datas/#{year}/#{place}/race_result.csv", {:encoding => 'UTF-8', :converters => nil})
        race_index = CSV.table("datas/#{year}/#{place}/index.csv", {:encoding => 'UTF-8', :converters => nil})
      end
    end
  end
end

prepare_race()