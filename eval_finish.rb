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
  (1..10).each do |i|
    place =  format("%02<number>d", number: i)
    top_finished = CSV.table("intermediate/finished/2020/#{place}/top_finished.csv", {:encoding => 'UTF-8', :converters => nil})
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
  end
  CSV.open("intermediate/finished/2020/top.csv", "w") do |csv| 
    finished_top_jst.each do |data|
      csv << data
    end
  end
end

jst_finish()