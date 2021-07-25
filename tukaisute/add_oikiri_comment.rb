require "csv"

def main
  year = "2020"
  (1..10).each do |i|
    place =  format("%02<number>d", number: i)
    CSV.open("datas/#{year}/#{place}/race_result_fixed_2.csv", "w") do |csv| 
      csv << "id,raceName,rank,frameNumber,horseNumber,horseName,horseId,sexAge,weight,jockeyName,jockeyId,time,timeDiff,timePoint,passingOrder,time3f,oddsNum,oddsRank,horseWeight,horseWeightDiff,memo,trainerId,arrangeTime,arrangeTimeDiff,oikiri,comment".split(",")
    end
    race_result = CSV.table("datas/#{year}/#{place}/race_result_fixed.csv", {:encoding => 'UTF-8', :converters => nil})
    #id,horseId,oikiri,comment
    oikiri = CSV.table("datas/#{year}/#{place}/oikiri_comment.csv", {:encoding => 'UTF-8', :converters => nil})
    oikiri_map = {}
    oikiri.each do |o|
      race_id = o[:id]
      horse_id = o[:horseid]
      if oikiri_map[race_id]
        oikiri_map[race_id][horse_id] = {oikiri: o[:oikiri], comment: o[:comment]}
      else
        oikiri_map[race_id] = {}
        oikiri_map[race_id][horse_id] = {oikiri: o[:oikiri], comment: o[:comment]}
      end
    end
    
    race_result.each do |r|
      tmp_races = []
      tmp_races << r

      tmp_races[0] << oikiri_map[r[:id]][r[:horseid]][:oikiri]
      tmp_races[0] << oikiri_map[r[:id]][r[:horseid]][:comment]
      write(tmp_races,year,place)
    end
  end
end

def write(tmp_races, year, place)
  CSV.open("datas/#{year}/#{place}/race_result_fixed_2.csv", "a") do |csv| 
    tmp_races.each do |race|
      csv << race
    end
  end
end

main()