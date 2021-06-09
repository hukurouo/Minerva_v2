require "csv"

def prepare_finish
  finished_top = "id,raceName,horseNumber,horseName,jockeyPoint,stallionPoint,trainerPoint".split(",")
  finished_wide = "id,raceName,horseNumber,horseName,jockeyPoint,stallionPoint,trainerPoint".split(",")

  place_map = {} 
  place_index = CSV.table("race_info.csv", {:encoding => 'UTF-8', :converters => nil})
  place_index.each do |place_index|
    place_map[place_index[:id]] = place_index[:place]
  end

  stallion_map = {} 
  stallion_index = CSV.table("intermediate/horse/horse_stallion_index.csv", {:encoding => 'UTF-8', :converters => nil})
  stallion_index.each do |stallion_index|
    stallion_map[stallion_index[:id]] = stallion_index[:stallion_id]
  end

  (1..10).each do |i|
    place =  format("%02<number>d", number: i)
    CSV.open("intermediate/finished/2020/#{place}/top_finished.csv", "w") do |csv| 
      csv << finished_top
    end
    CSV.open("intermediate/finished/2020/#{place}/wide_finished.csv", "w") do |csv| 
      csv << finished_wide
    end
    race_result = CSV.table("datas/2020/#{place}/race_result.csv", {:encoding => 'UTF-8', :converters => nil})
    race_index = CSV.table("datas/2020/#{place}/index.csv", {:encoding => 'UTF-8', :converters => nil})
    race_index_map = {}
    race_index.each do |r|
      race_index_map[r[:id]] = {raceName: r[:racename], courseType: r[:coursetype] ,courseLength: r[:courselength]}
    end
    race_result.each do |result|
      id = result[:id]
      place_name = place_map[place]
      course_type = race_index_map[id][:courseType]
      course_length = race_index_map[id][:courseLength]
      race_type = place_name + course_type + course_length
      
      jockey_data = CSV.table("intermediate/jockey/2017-2019/#{result[:jockeyid]}.csv", {:encoding => 'UTF-8', :converters => nil})
      stallion_data = CSV.table("intermediate/stallion/2017-2019/#{stallion_map[result[:horseid]]}.csv", {:encoding => 'UTF-8', :converters => nil})
      trainer_data = CSV.table("intermediate/trainer/2017-2019/#{result[:trainerid]}.csv", {:encoding => 'UTF-8', :converters => nil})

      #id,raceName,horseNumber,horseName,jockeyPoint,stallionPoint,trainerPoint
      top_row = [id, result[:racename], result[:horsenumber], result[:horsename]]
      wide_row = [id, result[:racename], result[:horsenumber], result[:horsename]]
      [jockey_data, stallion_data, trainer_data].each do |data|
        flag = true
        data.each do |d|
          if d[:race_type] == race_type
            flag = false
            top_row << d[:win_rate]
            wide_row << d[:win3_rate]
          end
        end
        if flag
          top_row << 0.0
          wide_row << 0.0
        end
      end
      write(top_row, place, "top_finished")
      write(wide_row, place, "wide_finished")
    end
  end

end

def write(data, place, csv_name)
  CSV.open("intermediate/finished/2020/#{place}/#{csv_name}.csv", "a") do |csv| 
    csv << data
  end
end

prepare_finish()