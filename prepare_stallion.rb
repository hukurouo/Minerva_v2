require "csv"

def eval_stallion
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
        race_index_map = {}
        race_index.each do |r|
          race_index_map[r[:id]] = {raceName: r[:racename], courseType: r[:coursetype] ,courseLength: r[:courselength]}
        end
        race_result.each do |result|
          if horse_list.include? result[:horseid]
            id = result[:id]
            place_name = place_map[place]
            course_type = race_index_map[id][:courseType]
            course_length = race_index_map[id][:courseLength]
            race_type = place_name + course_type + course_length
            rank = result[:rank]
            unless stallion_map[race_type]
              stallion_map[race_type] = [0,0,0,0]
              stallion_map[race_type] = add_result(stallion_map[race_type],rank)
            else
              stallion_map[race_type] = add_result(stallion_map[race_type],rank)
            end
          end
        end
      end
    end
    csv_rows = []
    stallion_map.each do |j|
      csv_row = []
      type = j[0]
      result = j[1]
      total = result.sum
      win_rate = (result[0].to_f / total * 100).round(1)
      win2_rate = ((result[0].to_f + result[1].to_f) / total * 100).round(1)
      win3_rate = ((result[0].to_f + result[1].to_f + result[2].to_f) / total * 100).round(1)
      csv_row << type
      csv_row += result + [total, win_rate, win2_rate, win3_rate]
      csv_rows << csv_row
    end
    csv_rows.unshift("race_type,rank1,rank2,rank3,rank_outside,total,win_rate,win2_rate,win3_rate".split(","))
    CSV.open("intermediate/stallion/2020/#{stallion[:stallionid]}.csv", "w") do |csv| 
      csv_rows.each do |data|
        csv << data
      end
    end
    p index
  end
end

def add_result(arr,rank)
  if rank == "1"
    arr[0] += 1
    return arr
  elsif rank == "2"
    arr[1] += 1
    return arr
  elsif rank == "3"
    arr[2] += 1
    return arr
  else
    arr[3] += 1
    return arr
  end
end

eval_stallion()