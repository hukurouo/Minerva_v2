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
  ]
  (1..11).each do |index|
    types << "run5_rank_total_#{(index*5).to_s}"
  end
  (-6..20).each do |index|
    types << "run5_timeDiff_total_#{(index).to_s}"
  end
  types.each do |type|
    result_arrange_map[type] = [0,0,0,0]
  end

  horse_2020.each_with_index do |id, index|
    horse = CSV.table("intermediate/result/2020/#{id}.csv", {:encoding => 'UTF-8', :converters => nil})
    horses = []
    horse.each do |h|
      horses << h
    end
    if horses.length > 5
      (5..horses.length-1).each do |i|
        rank = horses[i][:rank].to_f
        rank_sum = horses[i-5..i-1].map{|x|x[:rank].to_f}.sum
        time_diff_sum = horses[i-5..i-1].map{|x|x[:arrangetimediff].to_f}.sum
        (1..10).each do |index|
          if rank_sum.between?(index*5, (((index+1)*5)-1))
            result_arrange_map["run5_rank_total_#{(index*5).to_s}"][rank_num(horses[i])] += 1
          end
        end
        if rank_sum > 55
          result_arrange_map["run5_rank_total_55"][rank_num(horses[i])] += 1
        end
        (-6..20).each do |index|
          if time_diff_sum.between?(index, index+1)
            result_arrange_map["run5_timeDiff_total_#{(index).to_s}"][rank_num(horses[i])] += 1
          end
        end
      end
    end
  end

  result_arrange_map.each_value do |v|
    total = v.sum
    win_rate = (v[0].to_f / total * 100).round(1)
    wide_rate = ((v[0].to_f + v[1].to_f + v[2].to_f) / total * 100).round(1)
    v << win_rate.to_s + "%"
    v << wide_rate.to_s + "%"
  end

  CSV.open("output/result_research/2017-2020_run5.csv", "w") do |csv| 
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