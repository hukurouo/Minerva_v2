require "csv"

# 定数
@dir_name = "202107"
@file_name = "20210731"

def jst_finish
  finished_top_jst = ["id,horseNumber".split(",")]

  finished = CSV.table("today/#{@dir_name}/#{@file_name}/n_datas_ad.csv", {:encoding => 'UTF-8', :converters => nil})
  index = CSV.table("today/#{@dir_name}/#{@file_name}/index.csv", {:encoding => 'UTF-8', :converters => nil})
  index_map = {}
  index.each do |i|
    racename = ""
    course_type = ""
    if i[:name].include?("新馬")
      racename = "sinba"
    elsif i[:name].include?("未勝利")
      racename = "misyouri"
    elsif i[:name].include?("勝クラス")
      racename = "class"
    else
      racename = "zyouken"
    end
    if i[:coursetype] == "芝"
      course_type = "siba"
    else
      course_type = "dart"
    end
    index_map[i[:id]] = {place: i[:place], coef_name: [racename,course_type].join("_"), name: i[:name]}
  end
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
    tmp_point = eval_point(result,id,index_map)
    if tmp_point > point
      point = tmp_point
      top_result = [id,index_map[id][:name],result[:horsenumber],point.round(2)]
    end
  end
  finished_top_jst << top_result

  CSV.open("today/#{@dir_name}/#{@file_name}/top.csv", "w") do |csv| 
    finished_top_jst.each do |data|
      csv << data
    end
  end

end

def eval_point(result,id,index_map)
  set_coef(id,index_map)
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

def set_coef(id,index_map)
  place = index_map[id][:place]
  coef_name = index_map[id][:coef_name]
  coefs = CSV.table("intermediate/coefs/#{place}_coefs.csv", {:encoding => 'UTF-8', :converters => nil})
  coef = {}
  coefs.each do |c|
    if c[:name] == coef_name
      coef = c
    end
  end
  @jockey_coef,@stallion_coef,@trainer_coef,@frame_coef,@kyaku_coef,@oikiri_coef,@comment_coef,@timepoint_coef,@rank_coef,@tyakusa_coef = coef[:jockey].to_f,coef[:stallion].to_f,coef[:trainer].to_f,coef[:frame].to_f,coef[:kyaku].to_f,coef[:oikiri].to_f,coef[:comment].to_f,coef[:timepoint].to_f,coef[:rank].to_f,coef[:tyakusa].to_f
end
jst_finish()