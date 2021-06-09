require "csv"

def main
  (2017..2020).each do |year|
    year = year.to_s
    (1..10).each do |i|
      place =  format("%02<number>d", number: i)
      CSV.open("datas/#{year}/#{place}/race_result_fixed.csv", "w") do |csv| 
        csv << "id,raceName,rank,frameNumber,horseNumber,horseName,horseId,sexAge,weight,jockeyName,jockeyId,time,timeDiff,timePoint,passingOrder,time3f,oddsNum,oddsRank,horseWeight,horseWeightDiff,memo,trainerId,arrangeTime,arrangeTimeDiff".split(",")
      end
      race_result = CSV.table("datas/#{year}/#{place}/race_result.csv", {:encoding => 'UTF-8', :converters => nil})
      tmp_races= []
      id = race_result[0][:id]
      race_result.each do |r|
        if r[:id] != id
          #write
          arrange_time(tmp_races, year, place)
          #init
          tmp_races= []
          id = r[:id]
        end
        #update
        tmp_races << r
      end
      arrange_time(tmp_races, year, place)
    end
  end
end

def arrange_time(tmp_races, year, place)
  count = tmp_races.size
  raw_times = []
  tmp_races.each do |race|
    raw_times << race[:time]
  end
  mod_times = []
  raw_times.each do |time|
    if time.include? ":"
      min = time[0].to_f * 60
      sec = time.split(":")[1].to_f
      mod_times << (min+sec)
    else
      mod_times << time
    end
  end
  mod_diffs = [(mod_times[0] - mod_times[1]).round(2)]
  (1..count-1).each do |index|
    if mod_times[index] == ""
      mod_diffs << ""
    else
      mod_diffs << (mod_times[index] - mod_times[index-1]).round(2)
    end
  end
  tmp_races.each_with_index do |race, index|
    race << mod_times[index]
    race << mod_diffs[index]
  end
  CSV.open("datas/#{year}/#{place}/race_result_fixed.csv", "a") do |csv| 
    tmp_races.each do |race|
      csv << race
    end
  end
end

main()