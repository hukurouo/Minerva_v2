require "csv"

def today_log_eval()
  log_names = ["log_class_dart_sprint"]
  log_names.each do |log_name|
    place = "all"
    log = CSV.table("output/data_ana_v1/#{place}/#{log_name}.csv", {:encoding => 'UTF-8', :converters => nil})
    count = log[:jockey].size
    hit = log[:hit]
    #jockey,stallion,trainer,frame,kyaku,oikiri,comment,timepoint,rank,tyakusa
    jockey_ave = eval_ave(log[:jockey],hit,count)
    stallion_ave = eval_ave(log[:stallion],hit,count)
    trainer_ave = eval_ave(log[:trainer],hit,count)
    frame_ave = eval_ave(log[:frame],hit,count)
    kyaku_ave = eval_ave(log[:kyaku],hit,count)
    oikiri_ave = eval_ave(log[:oikiri],hit,count)
    comment_ave = eval_ave(log[:comment],hit,count)
    timepoint_ave = eval_ave(log[:timepoint],hit,count)
    rank_ave = eval_ave(log[:rank],hit,count)
    tyakusa_ave = eval_ave(log[:tyakusa],hit,count)
    rec_ave = eval_ave(log[:rec],hit,count)
    p log_name
    p ["jockey",jockey_ave,"stallion",stallion_ave,"trainer",trainer_ave,"frame",frame_ave,"kyaku",kyaku_ave,"oikiri",oikiri_ave,"comment",comment_ave,"time",timepoint_ave,"rank",rank_ave,"tyakusa",tyakusa_ave,"rec",rec_ave]
  end
end

def eval_ave(log,hit,count)
  count = 0
  valid_nums = []
  log.each_with_index do |l,i|
    if hit[i].to_f > 22
      valid_nums << l.to_f
      count += 1
    end
  end
  ave = (valid_nums.sum / count).round(3)
end


today_log_eval()