#id,raceName,rank,frameNumber,horseNumber,horseName,horseId,sexAge,weight,jockeyName,jockeyId,time,timeDiff,timePoint,passingOrder,time3f,oddsNum,oddsRank,horseWeight,horseWeightDiff,memo,trainerId,arrangeTime,arrangeTimeDiff,courseType,courseLength,courseDir,weather,courseStatus,courseStatusNum,date
require "csv"

def arrange_result
  horse_2020 = CSV.table("intermediate/horse/horse_index_2020.csv", {:encoding => 'UTF-8', :converters => nil}).map{|csv|csv[:id]}
  horse_2020_map = {}
  horse_2020.each do |id|
    horse_2020_map[id] = {}
  end
  result_arrange_map = {}

  #中n週別の戦績

  types = [
    "siba_omo_to_ryo",
    "siba_ryo_to_omo",
    "siba_omo_to_omo",
    "siba_ryo_to_ryo",
    "dart_omo_to_ryo",
    "dart_ryo_to_omo",
    "dart_omo_to_omo",
    "dart_ryo_to_ryo",
    "siba_to_dart",
    "dart_to_siba",
    "distance_extension",
    "distance_shortening",
    "distance_unchanged",
  ]
  (1..20).each do |index|
    types << "since_#{index.to_s}_weeks"
  end
  types.each do |type|
    result_arrange_map[type] = [0,0,0,0]
  end
  
  horse_2020.each_with_index do |id, index|
    horse = CSV.table("intermediate/result/2020/#{id}.csv", {:encoding => 'UTF-8', :converters => nil})
    course_status = horse[0][:coursestatus]
    course_type = horse[0][:coursetype]
    course_length = horse[0][:courselength]
    date = convert_d(horse[0])
    horse.each_with_index do |h,i|
      next if i == 0
      if h[:coursetype] == "芝"
        if ["重","不良"].include?(h[:coursestatus]) && course_status == "良"
          result_arrange_map["siba_ryo_to_omo"][rank_num(h)] += 1
        elsif ["重","不良"].include?(h[:coursestatus]) && ["重","不良"].include?(course_status)
          result_arrange_map["siba_omo_to_omo"][rank_num(h)] += 1
        elsif h[:coursestatus] == "良" && ["重","不良"].include?(course_status)
          result_arrange_map["siba_omo_to_ryo"][rank_num(h)] += 1
        elsif h[:coursestatus] == "良" && course_status == "良"
          result_arrange_map["siba_ryo_to_ryo"][rank_num(h)] += 1
        end
      elsif h[:coursetype] == "ダ"
        if ["重","不良"].include?(h[:coursestatus]) && course_status == "良"
          result_arrange_map["dart_ryo_to_omo"][rank_num(h)] += 1
        elsif ["重","不良"].include?(h[:coursestatus]) && ["重","不良"].include?(course_status)
          result_arrange_map["dart_omo_to_omo"][rank_num(h)] += 1
        elsif h[:coursestatus] == "良" && ["重","不良"].include?(course_status)
          result_arrange_map["dart_omo_to_ryo"][rank_num(h)] += 1
        elsif h[:coursestatus] == "良" && course_status == "良"
          result_arrange_map["dart_ryo_to_ryo"][rank_num(h)] += 1
        end
      end

      if h[:coursetype] == "芝" && course_type == "ダ"
        result_arrange_map["dart_to_siba"][rank_num(h)] += 1
      elsif h[:coursetype] == "ダ" && course_type == "芝"
        result_arrange_map["siba_to_dart"][rank_num(h)] += 1
      end

      if course_length.to_i > h[:courselength].to_i
        result_arrange_map["distance_shortening"][rank_num(h)] += 1
      elsif course_length.to_i < h[:courselength].to_i
        result_arrange_map["distance_extension"][rank_num(h)] += 1
      else  
        result_arrange_map["distance_unchanged"][rank_num(h)] += 1
      end

      middle_date = (convert_d(h) - date).to_i
      middle_week = middle_date / 7
      middle_week = 20 if middle_week >= 20
      middle_week = 1 if middle_week == 0
      result_arrange_map["since_#{middle_week.to_s}_weeks"][rank_num(h)] += 1

      course_status = h[:coursestatus]
      course_type = h[:coursetype]
      course_length = h[:courselength]
      date = convert_d(h)
    end
  end

  result_arrange_map.each_value do |v|
    total = v.sum
    win_rate = (v[0].to_f / total * 100).round(1)
    wide_rate = ((v[0].to_f + v[1].to_f + v[2].to_f) / total * 100).round(1)
    v << win_rate.to_s + "%"
    v << wide_rate.to_s + "%"
  end

  CSV.open("output/result_research/2017-2020.csv", "w") do |csv| 
    csv << "type,1,2,3,4位以下,勝率,複勝率".split(",")
    result_arrange_map.each do |data|
      csv << ([data[0]] + data[1])
    end
  end
end

def rank_num(h)
  num = 3
  num = 0 if h[:rank] == "1"
  num = 1 if h[:rank] == "2"
  num = 2 if h[:rank] == "3"
  num
end

def convert_d(h)
  date = Date.new(h[:date].split("/")[0].to_i, h[:date].split("/")[1].to_i, h[:date].split("/")[2].to_i)
end

arrange_result()