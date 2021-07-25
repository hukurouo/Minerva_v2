require "csv"

@dir_name = "2020_v5"

def prepare_finish
  finished_top = "id,raceName,horseNumber,horseName,jockeyPoint,stallionPoint,trainerPoint,timePoint,resultPoint,timeDiffPoint,oikiri,comment,rank".split(",")
  finished_wide = "id,raceName,horseNumber,horseName,jockeyPoint,stallionPoint,trainerPoint,timePoint,resultPoint,timeDiffPoint,oikiri,comment,rank".split(",")

  place_map = {} 
  place_index = CSV.table("race_info.csv", {:encoding => 'UTF-8', :converters => nil})
  place_index.each do |place_index|
    place_map[place_index[:id]] = place_index[:place]
  end

  stallion_map = {} 
  stallion_index = CSV.table("intermediate/stallion/horse_stallion_index.csv", {:encoding => 'UTF-8', :converters => nil})
  stallion_index.each do |stallion_index|
    stallion_map[stallion_index[:id]] = stallion_index[:stallion_id]
  end

  (1..10).each do |i|
    place =  format("%02<number>d", number: i)
    CSV.open("intermediate/finished/#{@dir_name}/#{place}/top_finished.csv", "w") do |csv| 
      csv << finished_top
    end
    CSV.open("intermediate/finished/#{@dir_name}/#{place}/wide_finished.csv", "w") do |csv| 
      csv << finished_wide
    end
    race_result = CSV.table("datas/2020/#{place}/race_result_fixed_2.csv", {:encoding => 'UTF-8', :converters => nil})
    race_index = CSV.table("datas/2020/#{place}/index_fixed.csv", {:encoding => 'UTF-8', :converters => nil})
    race_index_map = {}
    race_index.each do |r|
      race_index_map[r[:id]] = {raceName: r[:racename], courseType: r[:coursetype] ,courseLength: r[:courselength], date: r[:date]}
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

      #騎手・種牡馬・厩舎
      [jockey_data, stallion_data, trainer_data].each do |data|
        flag = true
        data.each do |d|
          if d[:race_type] == race_type
            flag = false
            total = d[:total].to_f
            coef = 1
            coef = 0.2 if total.between?(1, 2)  
            coef = 0.4 if total.between?(3, 5)  
            coef = 0.6 if total.between?(6, 7)
            coef = 0.8 if total.between?(8, 10)
            top_row << (d[:win_rate].to_f * coef).round(1)
            wide_row << (d[:win3_rate].to_f * coef).round(1)         
          end
        end
        if flag
          top_row << 0.0
          wide_row << 0.0
        end
      end

      #タイム指数
      horse_data = CSV.table("intermediate/result/2020/#{result[:horseid]}.csv", {:encoding => 'UTF-8', :converters => nil})
      result_count = 5
      result_count = horse_data.size if horse_data.size <= 5
      time_points = []
      race_date = convert_d(race_index_map[id][:date]) #これが基準日
      horse_data.each do |h|
        if race_date > convert_d(h[:date])
          time_points << h[:timepoint].to_f
        end
      end
      time_point = 0
      count = 5
      count = time_points.size if time_points.size < 5
      time_point = time_points.last(5).sum / count if count != 0
      top_row << time_point.round(1)
      wide_row << time_point.round(1)

      #順位
      ranks = []
      horse_data.each do |h|
        if race_date > convert_d(h[:date])
          ranks << h[:rank].to_f
        end
      end
      rank_point = 0
      count = 5
      count = ranks.size if ranks.size < 5
      div = 0
      div = (ranks.last(5).sum * (5.0 / count)) if count != 0 
      rank_point = 500.0 / div if div != 0
      top_row << rank_point.round(1)
      wide_row << rank_point.round(1)

      #着差
      tyakusa = []
      horse_data.each do |h|
        if race_date > convert_d(h[:date])
          tyakusa << h[:arrangetimediff].to_f
        end
      end
      tyakusa_point = 0
      count = 5
      count = tyakusa.size if tyakusa.size < 5
      tyakusa_point = (tyakusa.last(5).sum * (5.0 / count)) if count != 0
      top_row << tyakusa_point.round(1)
      wide_row << tyakusa_point.round(1)

      #調教
      oikiri_point = 0
      oikiri_point = 20 if result[:oikiri] == "B"
      oikiri_point = 40 if result[:oikiri] == "A"
      top_row << oikiri_point
      wide_row << oikiri_point

      #厩舎コメント
      comment_point = 0
      comment_point = 20 if result[:comment] == "02"
      comment_point = 40 if result[:comment] == "01"
      top_row << comment_point
      wide_row << comment_point

      #rank
      top_row << result[:rank]
      wide_row << result[:rank]

      if /\d/.match(result[:rank]) && !result[:rank].include?("降")
        write(top_row, place, "top_finished")
        write(wide_row, place, "wide_finished")
      end
    end
  end

end

def write(data, place, csv_name)
  CSV.open("intermediate/finished/#{@dir_name}/#{place}/#{csv_name}.csv", "a") do |csv| 
    csv << data
  end
end

def convert_d(date_raw)
  date = Date.new(date_raw.split("/")[0].to_i, date_raw.split("/")[1].to_i, date_raw.split("/")[2].to_i)
end

def round_point()
  (1..10).each do |i|
    place =  format("%02<number>d", number: i)
    ["top_finished","wide_finished"].each do |csv_name|
      finished = CSV.table("intermediate/finished/#{@dir_name}/#{place}/#{csv_name}.csv", {:encoding => 'UTF-8', :converters => nil})
      finished_bulk = []
      race_id = finished[0][:id]
      finished.each do |f|
        if f[:id] != race_id
          add_round(finished_bulk)
          return
          finished_bulk = []
          race_id = f[:id] 
        end
        finished_bulk << f
      end
    end
  end
end

def add_round(finished_bulk)
  #jockeyPoint,stallionPoint,trainerPoint,timePoint
  jockey_points = []
  stallion_points = []
  trainer_points = []
  time_points = []
  finished_bulk.each do |f|
    jockey_points << f[:jockeypoint].to_f
    stallion_points << f[:stallionpoint].to_f
    trainer_points << f[:trainerpoint].to_f
    time_points << f[:timepoint].to_f
  end
  round_jockey_points = jockey_points.map{|j|j/jockey_points.max*5}
  p round_jockey_points
end

prepare_finish()
#round_point()