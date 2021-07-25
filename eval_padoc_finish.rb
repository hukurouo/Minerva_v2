require "csv"

# 定数
@jockey_coef = ARGV[0].to_f
@stallion_coef = ARGV[1].to_f 
@trainer_coef = ARGV[2].to_f
@timepoint_coef = ARGV[3].to_f
@rank_coef = ARGV[4].to_f
@oikiri_coef = ARGV[5].to_f
@comment_coef = ARGV[6].to_f
@padoc_coef = ARGV[7].to_f
@framepoint_coef = ARGV[8].to_f
@kyakupoint_coef = ARGV[9].to_f
@tyakusapoint_coef = ARGV[10].to_f

@finished_dir_name = "today/2021/finished"

def eval_padoc_finish_tan()
  top_finished = CSV.table("today/2021/valid-padoc-train-data-tan.csv", {:encoding => 'UTF-8', :converters => nil})
  results = []
  id = top_finished[0][:id]
  point = 0
  top_result = []
  top_finished.each do |t|
    result = t
    
    #write
    if result[:id] != id
      results << top_result if point != 0
      #init
      id = result[:id]
      point = 0
      top_result = []
    end
    #update
    tmp_point = \
      result[:jockeypoint].to_f * @jockey_coef + \
      result[:stallionpoint].to_f * @stallion_coef + \
      result[:trainerpoint].to_f * @trainer_coef + \
      result[:timepoint].to_f * @timepoint_coef + \
      result[:rankpoint].to_f * -1 * @rank_coef + \
      result[:oikiri].to_f * @oikiri_coef + \
      result[:comment].to_f * @comment_coef + \
      result[:padoc].to_f * 20 * @padoc_coef + \
      result[:framepoint].to_f * @framepoint_coef + \
      result[:kyakupoint].to_f * @kyakupoint_coef + \
      result[:tyakusapoint].to_f * -1 * @tyakusapoint_coef
    #id,horseId,jockeyPoint,stallionPoint,trainerPoint,oikiri,comment,padoc,framePoint,kyakuPoint,timePoint,rankPoint,tyakusaPoint,rank,rank_odds,horseNumber

    if tmp_point > point
      point = tmp_point
      top_result = [result[:id],result[:rank], result[:rank_odds]]
    end
  end
  results << top_result
  hit = 0
  rec = 0
  results.each do |r|
    hit += 1 if r[1] == "1"
    rec += r[2].to_f if r[1] == "1"
  end
  log_raw = [
    @jockey_coef,
    @stallion_coef,
    @trainer_coef,
    @timepoint_coef,
    @rank_coef,
    @oikiri_coef,
    @comment_coef,
    @padoc_coef,
    @framepoint_coef,
    @kyakupoint_coef,
    @tyakusapoint_coef,
    hit,
    rec.round(2)
  ]
  #CSV.open("#{@finished_dir_name}/tan.csv", "w") do |csv| 
  #  results.each do |data|
  #    csv << data
  #  end
  #end
  if rec > 250
    CSV.open("#{@finished_dir_name}/tan_log.csv", "a") do |csv| 
      csv << log_raw
    end
  end
end

eval_padoc_finish_tan()