require "csv"

# 定数
@racename = ARGV[0]
@coursetype = ARGV[1]
@courselength = ARGV[2]

coefs = CSV.table("intermediate/coefs/data_coefs.csv", {:encoding => 'UTF-8', :converters => nil})
coef_name = [@racename,@coursetype,@courselength].join("_")
coef = {}
coefs.each do |c|
  if c[:name] == coef_name
    coef = c
  end
end
@jockey_coef,@stallion_coef,@trainer_coef,@frame_coef,@kyaku_coef,@oikiri_coef,@comment_coef,@timepoint_coef,@rank_coef,@tyakusa_coef = coef[:jockey].to_f,coef[:stallion].to_f,coef[:trainer].to_f,coef[:frame].to_f,coef[:kyaku].to_f,coef[:oikiri].to_f,coef[:comment].to_f,coef[:timepoint].to_f,coef[:rank].to_f,coef[:tyakusa].to_f

def jst_finish
  finished_top_jst = ["id,horseNumber".split(",")]
  finished_wide_jst = ["id,horseNumber,widePoint".split(",")]
  (1..10).each do |i|
    place =  format("%02<number>d", number: i)

    finished = CSV.table("intermediate/datas/#{place}/n_datas_ad.csv", {:encoding => 'UTF-8', :converters => nil})
    id = finished[0][:id]
    point = -10000
    top_result = [] # [result[:id],result[:horsenumber], result[:horsename]]

    finished.each do |result|
      #write
      if result[:id] != id
        finished_top_jst << top_result if point != 0
        #init
        id = result[:id]
        point = -10000
        top_result = []
      end
      #update
      jockey_top = result[:jockeypointtop].to_f * @jockey_coef
      stallion_top = result[:stallionpointtop].to_f * @stallion_coef
      trainer_top =  result[:trainerpointtop].to_f * @trainer_coef
      frame_top = result[:framepointtop].to_f * @frame_coef
      kyaku_top = result[:kyakupointtop].to_f * @kyaku_coef
      oikiri = result[:oikiri].to_f * @oikiri_coef
      comment = result[:comment].to_f * @comment_coef
      time_top = result[:timepointtop].to_f * @timepoint_coef
      rank = result[:rankpoint].to_f * @rank_coef * -1
      tyakusa = result[:tyakusapoint].to_f * @tyakusa_coef * -1
      tmp_point = jockey_top + stallion_top + trainer_top + frame_top + kyaku_top + oikiri + comment + time_top + rank + tyakusa
      if tmp_point > point
        point = tmp_point
        top_result = [result[:id],result[:horsenumber]]
      end
    end
    finished_top_jst << top_result
    CSV.open("intermediate/finished/data_analysis/#{place}/top.csv", "w") do |csv| 
      finished_top_jst.each do |data|
        csv << data
      end
    end
  end
end

jst_finish()