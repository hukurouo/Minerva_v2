require "csv"

# 定数
@jockey_coef = ARGV[0].to_f  
@stallion_coef = ARGV[1].to_f  
@trainer_coef = ARGV[2].to_f 
@frame_coef = ARGV[3].to_f
@kyaku_coef = ARGV[4].to_f
@oikiri_coef = ARGV[5].to_f
@comment_coef = ARGV[6].to_f
@timepoint_coef = ARGV[7].to_f
@rank_coef = ARGV[8].to_f
@tyakusa_coef = ARGV[9].to_f

@dir_name = "202107"
@file_name = "20210725"

def jst_finish
  finished_top_jst = ["id,horseNumber".split(",")]

  finished = CSV.table("today/#{@dir_name}/#{@file_name}/n_datas.csv", {:encoding => 'UTF-8', :converters => nil})
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
    tmp_point = eval_point(result)
    if tmp_point > point
      point = tmp_point
      top_result = [result[:id],result[:horsenumber],point]
    end
  end
  finished_top_jst << top_result

  CSV.open("today/#{@dir_name}/#{@file_name}/top.csv", "w") do |csv| 
    finished_top_jst.each do |data|
      csv << data
    end
  end

end

def eval_point(result)
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
end

jst_finish()