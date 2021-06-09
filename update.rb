require "csv"

@jockey_coef = 1
@stallion_coef = 1
@trainer_coef = 1

def update
  system("ruby eval_finish.rb #{@jockey_coef} #{@stallion_coef} #{@trainer_coef }")
  system("ruby performance.rb")
  write()
end

def write()
  performance = CSV.table("output/sandbox_v1(17-20)/新馬/top.csv", {:encoding => 'UTF-8', :converters => nil})
  hit = performance[0]
  rec = performance[1]
  csv_row = [@jockey_coef,@stallion_coef,@trainer_coef]
  csv_row2 = [@jockey_coef,@stallion_coef,@trainer_coef]
  hit.each_with_index do |h,i|
    next if i == 0
    next unless h[1]
    csv_row.push h[1].strip
  end
  rec.each_with_index do |r,i|
    next if i == 0
    next unless r[1]
    csv_row2.push r[1].strip
  end

  CSV.open('output/sandbox_v1(17-20)/新馬/top_hit_log.csv','a') do |csv| 
    csv << csv_row
  end

  CSV.open('output/sandbox_v1(17-20)/新馬/top_rec_log.csv','a') do |csv| 
    csv << csv_row2
  end

end

def auto
  [0.0,0.3,0.6,0.9].each do |i|
    [0.0,0.3,0.6,0.9].each do |j|
      [0.0,0.3,0.6,0.9].each do |k|
        @jockey_coef = i
        @stallion_coef = j
        @trainer_coef = k
        update()
      end
    end
  end
end

auto()