require "csv"

def performance
  top = CSV.table("intermediate/finished/2020/top.csv", {:encoding => 'UTF-8', :converters => nil})
  top_map = {}
  top.each do |t|
    top_map[t[:id]] = {horseNumber: t[:horsenumber], horseName: t[:horsename]}
  end
 
  result = []
  (1..10).each do |i|
    place =  format("%02<number>d", number: i)
    index = CSV.table("datas/2020/#{place}/index.csv", {:encoding => 'UTF-8', :converters => nil})
    race_result = CSV.table("datas/2020/#{place}/race_result.csv", {:encoding => 'UTF-8', :converters => nil})
    race_result_map = {}
    race_result.each do |r|
      if r[:rank] == "1"
        race_result_map[r[:id]] = {horseNumber: r[:horsenumber], raceName: r[:racename]}
      end
    end
    odds = CSV.table("datas/2020/#{place}/odds.csv", {:encoding => 'UTF-8', :converters => nil})
    odds_map = {}
    odds.each do |o|
      if o[:type] == "単勝"
        odds_map[o[:id]] = o[:odds]
      end
    end
    index.each do |j|
      next unless j[:racename].include?("新馬")
      id = j[:id]
      finished_top_number = top_map[id][:horseNumber] if top_map[id]
      top_horse_number = race_result_map[id][:horseNumber]
      odds = odds_map[id].to_f
      if top_horse_number == finished_top_number
        result << [race_result_map[id][:raceName], odds*10 -1000]
      else
        result << [race_result_map[id][:raceName], -1000]
      end
    end
  end
  total = total_eval(result)
  result.unshift(["----------"])
  result.unshift(["total", total[0]])
  result.unshift(["reco_rate", total[1]])
  result.unshift(["hit_rate", total[2]])
  result.unshift(["name","odds"])
  CSV.open("output/sandbox_v1(17-20)/新馬/top.csv", "w") do |csv| 
    result.each do |data|
      csv << data
    end
  end
end

def total_eval(top)
  total = 0
  count = top.size()
  total_amount = count * 1000
  hit_count = 0
  top.each do |t|
    total += t[1].to_i
    if t[1].to_i != -1000
      hit_count += 1
    end
  end
  hit_rate = hit_count.to_f / count * 100
  recovery_rate = ((total_amount + total).to_f / (total_amount)) * 100
  totals = [total, recovery_rate.round(2).to_s + "%", hit_rate.round(2).to_s + "%"]
  p totals
end

performance()
