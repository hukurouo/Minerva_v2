require "csv"

# 定数
@jockey_coef = ARGV[0].to_f  
@stallion_coef = ARGV[1].to_f  
@trainer_coef = ARGV[2].to_f 

def simple_finish
  finished_top = ["id,horseNumber,horseName".split(",")]
  (1..10).each do |i|
    place =  format("%02<number>d", number: i)
    race_result = CSV.table("datas/2020/#{place}/race_result.csv", {:encoding => 'UTF-8', :converters => nil})
    race_result.each do |result|
      if result[:oddsrank] == "1"
        finished_top << [result[:id],result[:horsenumber], result[:horsename]]
      end
    end
    p "done" + i.to_s
  end
  CSV.open("intermediate/finished/2020/odds_rank_1_top.csv", "w") do |csv| 
    finished_top.each do |data|
      csv << data
    end
  end
end

#simple_finish()

def jst_finish
  finished_top_jst = ["id,horseNumber,horseName".split(",")]
  finished_wide_jst = ["id,horseNumber".split(",")]
  (1..10).each do |i|
    place =  format("%02<number>d", number: i)
    top_finished = CSV.table("intermediate/finished/2020_v2/#{place}/top_finished.csv", {:encoding => 'UTF-8', :converters => nil})
    id = top_finished[0][:id]
    point = 0
    top_result = [] # [result[:id],result[:horsenumber], result[:horsename]]

    top_finished.each do |result|
      #write
      if result[:id] != id
        finished_top_jst << top_result if point != 0
        #init
        id = result[:id]
        point = 0
        top_result = []
      end
      #update
      tmp_point = result[:jockeypoint].to_f * @jockey_coef + result[:stallionpoint].to_f * @stallion_coef + result[:trainerpoint].to_f * @trainer_coef
      if tmp_point > point
        point = tmp_point
        top_result = [result[:id],result[:horsenumber], result[:horsename]]
      end
    end
    finished_top_jst << top_result

    wide_finished = CSV.table("intermediate/finished/2020_v2/#{place}/wide_finished.csv", {:encoding => 'UTF-8', :converters => nil})
    id = wide_finished[0][:id]
    wide_result = []
    wide_finished.each do |result|
      #write
      if result[:id] != id
        sorted = wide_result.sort_by{|x| x[:point]*-1 }
        horse_nums = sorted.map{|x|x[:horsenumber]}[0..4]
        finished_wide_jst << [id, horse_nums.join(",")]
        #init
        id = result[:id]
        wide_result = []
      end
      #update
      tmp_point = result[:jockeypoint].to_f * @jockey_coef + result[:stallionpoint].to_f * @stallion_coef + result[:trainerpoint].to_f * @trainer_coef
      result[:point] = tmp_point
      wide_result << result
    end
    sorted = wide_result.sort_by{|x| x[:point]*-1 }
    horse_nums = sorted.map{|x|x[:horsenumber]}[0..4]
    finished_wide_jst << [wide_finished[wide_finished.size-1][:id], horse_nums.join(",")]
  end

  CSV.open("intermediate/finished/2020_v2/top.csv", "w") do |csv| 
    finished_top_jst.each do |data|
      csv << data
    end
  end

  CSV.open("intermediate/finished/2020_v2/wide.csv", "w") do |csv| 
    finished_wide_jst.each do |data|
      csv << data
    end
  end

end

jst_finish()