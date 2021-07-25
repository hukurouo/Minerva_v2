require "csv"

def today_log_eval()
  log_names = ["log","log_siba","log_dart"]
  log_names.each do |log_name|
    place = "04"
    log = CSV.table("output/data_ana_v1/#{place}/#{log_name}.csv", {:encoding => 'UTF-8', :converters => nil})
    count = log[:jockey].size
    #jockey,stallion,trainer,frame,kyaku,oikiri,comment,timepoint,rank,tyakusa
    jockey_ave = (log[:jockey].map{|x|x.to_f}.sum / count).round(3)
    stallion_ave = (log[:stallion].map{|x|x.to_f}.sum / count).round(3)
    trainer_ave = (log[:trainer].map{|x|x.to_f}.sum / count).round(3)
    frame_ave = (log[:frame].map{|x|x.to_f}.sum / count).round(3)
    kyaku_ave = (log[:kyaku].map{|x|x.to_f}.sum / count).round(3)
    oikiri_ave = (log[:oikiri].map{|x|x.to_f}.sum / count).round(3)
    comment_ave = (log[:comment].map{|x|x.to_f}.sum / count).round(3)
    timepoint_ave = (log[:timepoint].map{|x|x.to_f}.sum / count).round(3)
    rank_ave = (log[:rank].map{|x|x.to_f}.sum / count).round(3)
    tyakusa_ave = (log[:tyakusa].map{|x|x.to_f}.sum / count).round(3)
    p log_name
    p ["jockey",jockey_ave,"stallion",stallion_ave,"trainer",trainer_ave,"frame",frame_ave,"kyaku",kyaku_ave,"oikiri",oikiri_ave,"comment",comment_ave,"time",timepoint_ave,"rank",rank_ave,"tyakusa",tyakusa_ave]
  end
end

today_log_eval()