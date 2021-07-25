require "csv"

@finished_dir_name = "2020_v5"
@file_name = "finished_2020_g"

def matome
  finished_top_matome = ["id,raceName,horseNumber,horseName,jockeyPoint,stallionPoint,trainerPoint,timePoint,resultPoint,timeDiffPoint,oikiri,comment,rank".split(",")]
  finished_wide_matome = ["id,raceName,horseNumber,horseName,jockeyPoint,stallionPoint,trainerPoint,timePoint,resultPoint,timeDiffPoint,oikiri,comment,rank".split(",")]
  (1..10).each do |i|
    place =  format("%02<number>d", number: i)
    top_finished = CSV.table("intermediate/finished/#{@finished_dir_name}/#{place}/top_finished.csv", {:encoding => 'UTF-8', :converters => nil})
    wide_finished = CSV.table("intermediate/finished/#{@finished_dir_name}/#{place}/wide_finished.csv", {:encoding => 'UTF-8', :converters => nil})
    top_finished.each do |t|
      if t[:racename].include?("(G")
        finished_top_matome << t
      end
    end
    wide_finished.each do |w|
      if w[:racename].include?("(G")
        finished_wide_matome << w
      end
    end
  end
  CSV.open("intermediate/finished/#{@finished_dir_name}/#{@file_name}_top.csv", "w") do |csv| 
    finished_top_matome.each do |data|
      csv << data
    end
  end
  CSV.open("intermediate/finished/#{@finished_dir_name}/#{@file_name}_wide.csv", "w") do |csv| 
    finished_wide_matome.each do |data|
      csv << data
    end
  end
end

matome()