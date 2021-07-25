require "csv"

#未勝利 0.5,1.0,0.0,0.9,0.2,21.14%,17.8%,33.66%,69.55%,111.44%,79.56%
#条件戦 0.5,1.0,0.0,0.8,0.0,16.49%,14.18%,28.36%,69.53%,123.04%,99.07%
@jockey_coef = 0.5
@stallion_coef = 1
@trainer_coef = 0
@timepoint_coef = 0.8
@result_coef = 0.0
@oikiri_coef = 1
@comment_coef = 1

def update
  system("ruby eval_finish.rb #{@jockey_coef} #{@stallion_coef} #{@trainer_coef} #{@timepoint_coef} #{@result_coef} #{@oikiri_coef} #{@comment_coef}")
  system("ruby performance.rb")
  write()
end

def write()
  performance = CSV.table("output/sandbox_v6(17-20)/重賞/performance.csv", {:encoding => 'UTF-8', :converters => nil})
  hit = performance[0]
  rec = performance[1]
  csv_row = [@jockey_coef,@stallion_coef,@trainer_coef,@timepoint_coef,@result_coef,@oikiri_coef,@comment_coef]
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

  CSV.open('output/sandbox_v6(17-20)/重賞/log.csv','a') do |csv| 
    csv << csv_row
  end

end

# 0.5,1.0,0.0,0.75,0.0
# 0.5,1.0,0.0,1.0,0.0,
# 0.5,1.0,0.0,0.8,0.0
def auto
  #[0.4,0.5,0.6].each do |i|
    #[0.9,1.0,1.1].each do |j|
      #[0.0,0.1,0.2].each do |k|
        [0,0.2,0.4,0.6,0.8,1.0,1.2,1.4].each do |l|
          [0,0.2,0.4,0.6,0.8,1.0,1.2,1.4].each do |m|
            #@jockey_coef = i
            #@stallion_coef = j
            #@trainer_coef = k
            #@timepoint_coef = l
            #@result_coef = m
            @oikiri_coef = l
            @comment_coef = m
            update()
          end
        end
      #end
    #end
  #end
end

auto()
#update()