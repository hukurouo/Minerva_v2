require "csv"

# 04siba　新潟
#@jockey_coef,@stallion_coef,@trainer_coef,@frame_coef,@kyaku_coef,@oikiri_coef,@comment_coef,@timepoint_coef,@rank_coef,@tyakusa_coef = 0,1,0,1,0,1,1,1,1,1
# 04dart　新潟
#@jockey_coef,@stallion_coef,@trainer_coef,@frame_coef,@kyaku_coef,@oikiri_coef,@comment_coef,@timepoint_coef,@rank_coef,@tyakusa_coef = 0,1,1,0,0,0,1,1,1,0
# 02siba 函館
#@jockey_coef,@stallion_coef,@trainer_coef,@frame_coef,@kyaku_coef,@oikiri_coef,@comment_coef,@timepoint_coef,@rank_coef,@tyakusa_coef = 1,0,0,1,0,1,0,1,1,1
# 02dart 函館
#@jockey_coef,@stallion_coef,@trainer_coef,@frame_coef,@kyaku_coef,@oikiri_coef,@comment_coef,@timepoint_coef,@rank_coef,@tyakusa_coef = 0,1,0,1,0,0,1,1,1,0

@place = "04"

#@coursetype = "dart"
#@courselength_min = 0
#@courselength_max = 1600
#@courselength_name = "sprint"
#@racename = "class"

def update
  #system("ruby today_eval.rb #{@jockey_coef} #{@stallion_coef} #{@trainer_coef} #{@frame_coef} #{@kyaku_coef} #{@oikiri_coef} #{@comment_coef} #{@timepoint_coef} #{@rank_coef} #{@tyakusa_coef}")
  system("ruby today_eval_today.rb")
  #["siba","dart"].each do |coursetype|
  #  ["misyouri","sinba","class"].each do |racename|
  #    #system("ruby today_eval_inspect.rb #{racename} #{coursetype} #{"sprint"}")
  #    system("ruby today_performance.rb #{coursetype} #{racename}")
  #    write(racename,coursetype)
  #  end
  #end

  #system("ruby today_performance.rb #{@coursetype} #{@courselength_min} #{@courselength_max} #{@racename}")
  #write(@racename,@coursetype,@courselength_name)

  #system("ruby today_performance.rb #{"dart"} #{1600} #{5000} #{"sinba"}")
  #write("sinba","dart","inter")

  #system("ruby today_performance.rb #{"dart"} #{0} #{1600} #{"sinba"}")
  #write("sinba","dart","sprint")

  #system("ruby today_performance.rb #{"siba"} #{"sinba"}")
  #write("sinba","siba")

  #system("ruby today_performance.rb #{"siba"} #{0} #{1600} #{"sinba"}")
  #write("sinba","siba","sprint")
end

def write(racename,coursetype)
  performance = CSV.table("output/data_ana_v1/#{@place}/performance.csv", {:encoding => 'UTF-8', :converters => nil})
  hit = performance[0]
  rec = performance[1]
  csv_row = [@jockey_coef,@stallion_coef,@trainer_coef,@frame_coef,@kyaku_coef,@oikiri_coef,@comment_coef,@timepoint_coef,@rank_coef,@tyakusa_coef]
  hit.each_with_index do |h,i|
    next if i == 0
    next unless h[1]
    csv_row.push h[1].strip
  end
  rec.each_with_index do |r,i|
    next if i == 0
    next unless r[1]
    csv_row.push r[1].strip
  end
  rec_perc = csv_row.last.to_f
  hit_perc = csv_row[10].to_f
  if rec_perc > 100 && hit_perc > 20
    CSV.open("output/data_ana_v1/#{@place}/log_#{racename}_#{coursetype}.csv",'a') do |csv| 
      csv << csv_row
    end
  end
  CSV.open("output/data_ana_v1/#{@place}/all_log/log_#{racename}_#{coursetype}_all.csv",'a') do |csv| 
    csv << csv_row
  end
end

# 0.5,1.0,0.0,0.75,0.0
# 0.5,1.0,0.0,1.0,0.0,
# 0.5,1.0,0.0,0.8,0.0
def auto
  [0,0.5,1].each do |i|
    [0,0.5,1].each do |j|
      [0,0.5,1].each do |k|
        [0,0.5,1].each do |l|
          [0].each do |m|
            [0,0.5,1].each do |n|
              [0,0.5,1].each do |o|
                [0].each do |pp|
                  [0].each do |q|
                    [0].each do |r|
                      @jockey_coef = i
                      @stallion_coef = j
                      @trainer_coef = k
                      @frame_coef = l
                      @kyaku_coef = m
                      @oikiri_coef = n
                      @comment_coef = o
                      @timepoint_coef = pp
                      @rank_coef = q
                      @tyakusa_coef = r
                      update()
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

#auto()
update()