require "csv"

def create_horse
  results_header = "id,raceName,rank,frameNumber,horseNumber,horseName,horseId,sexAge,weight,jockeyName,jockeyId,time,timeDiff,timePoint,passingOrder,time3f,oddsNum,oddsRank,horseWeight,horseWeightDiff,memo,trainerId,arrangeTime,arrangeTimeDiff,courseType,courseLength,courseDir,weather,courseStatus,courseStatusNum,date".split(",")

  horse_2020 = CSV.table("intermediate/horse/horse_index_2020.csv", {:encoding => 'UTF-8', :converters => nil}).map{|csv|csv[:id]}
  horse_2020_map = {}
  horse_2020.each do |id|
    horse_2020_map[id] = {}
  end
  
  (2017..2020).each do |year|
    year = year.to_s
    (1..10).each do |i|
      place =  format("%02<number>d", number: i)
      race_result = CSV.table("datas/#{year}/#{place}/race_result_fixed.csv", {:encoding => 'UTF-8', :converters => nil})
      race_index = CSV.table("datas/#{year}/#{place}/index_fixed.csv", {:encoding => 'UTF-8', :converters => nil})
      race_index_map = {}
      race_index.each do |r|
        race_index_map[r[:id]] = {
          courseType: r[:coursetype] ,
          courseLength: r[:courselength],
          courseDir: r[:coursedir],
          weather: r[:weather],
          courseStatus: r[:coursestatus], 
          courseStatusNum: r[:coursestatusnum], 
          date: r[:date]
        }
      end
      race_result.each do |result|
        if horse_2020.include? result[:horseid]
          horse_2020_map[result[:horseid]][result[:id]] = result.to_a.map{|r|r[1]} + race_index_map[result[:id]].to_a.map{|r|r[1]}
        end
      end
    end
    p year
  end
  horse_2020_map.each do |horse_result|
    horse_result[1] = horse_result[1].sort_by{|x| Date.new(x[1].last.split("/")[0].to_i, x[1].last.split("/")[1].to_i, x[1].last.split("/")[2].to_i)}
    CSV.open("intermediate/result/2020/#{horse_result[0]}.csv", "w") do |csv| 
      csv << results_header
      horse_result[1].each do |data|
        csv << data[1]
      end
    end
  end
end

create_horse()