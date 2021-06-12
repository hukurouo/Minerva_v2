require "csv"

def performance
  top = CSV.table("intermediate/finished/2020_v2/top.csv", {:encoding => 'UTF-8', :converters => nil})
  top_map = {}
  top.each do |t|
    top_map[t[:id]] = {horseNumber: t[:horsenumber], horseName: t[:horsename]}
  end
  wide = CSV.table("intermediate/finished/2020_v2/wide.csv", {:encoding => 'UTF-8', :converters => nil})
  wide_map = {}
  wide.each do |t|
    wide_map[t[:id]] = t[:horsenumber]
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
        odds_map[o[:id]] = {}
        odds_map[o[:id]][:tan] = o[:odds]
      end
    end

    id = odds[0][:id]
    wide = []
    odds.each do |o|
      if o[:id] != id
        odds_map[id][:wide] = wide
        id = o[:id]
        wide = []
      end
      if o[:type] == "ワイド"
        wide << {horse_number: o[:horsenumber], odds:o[:odds].to_f}
      end
    end
    odds_map[id][:wide] = wide

    index.each do |j|
      next unless j[:racename].include?("新馬")
      id = j[:id]
      
      top_1 = top_map[id][:horseNumber] if top_map[id]
      top_number = race_result_map[id][:horseNumber]

      finished_wide_number = wide_map[id] if wide_map[id]
      wide_1 = finished_wide_number.split(",")[0]
      wide_2 = finished_wide_number.split(",")[1]
      wide_3 = finished_wide_number.split(",")[2]
      wide3ten = [wide_1,wide_2,wide_3]
      wide2ten = [wide_1,wide_2]
      tan_odds = odds_map[id][:tan].to_f
      result_row = [race_result_map[id][:raceName]]
      #単勝
      if top_number == top_1
        result_row << tan_odds*10 -1000
      else
        result_row << -1000
      end
      #ワイド
      result_row << wide_calc(wide2ten,odds_map[id][:wide])
      result << result_row
    end
  end
  total = total_eval(result)
  result.unshift(["----------"])
  result.unshift(["total", total[0][0], total[1][0]])
  result.unshift(["reco_rate", total[0][1], total[1][1]])
  result.unshift(["hit_rate", total[0][2], total[1][2]])
  result.unshift(["name","tan","wide"])
  CSV.open("output/sandbox_v2(17-20)/新馬/performance.csv", "w") do |csv| 
    result.each do |data|
      csv << data
    end
  end
end

def total_eval(top)
  total = 0
  total_wide=0
  count = top.size()
  total_amount = count * 1000
  total_amount_wide = count * 1000
  hit_count = 0
  hit_count_wide = 0
  top.each do |t|
    total += t[1].to_i
    total_wide += t[2].to_i
    if t[1].to_i != -1000
      hit_count += 1
    end
    if t[2].to_i != -1000
      hit_count_wide += 1
    end
  end
  hit_rate = hit_count.to_f / count * 100
  recovery_rate = ((total_amount + total).to_f / (total_amount)) * 100
  hit_rate_wide = hit_count_wide.to_f / count * 100
  recovery_rate_wide = ((total_amount_wide + total_wide).to_f / (total_amount_wide)) * 100
  totals = [[total, recovery_rate.round(2).to_s + "%", hit_rate.round(2).to_s + "%"],[total_wide, recovery_rate_wide.round(2).to_s + "%", hit_rate_wide.round(2).to_s + "%"]]
  p totals
end

def wide_calc(box,odds)
  wide_money = -1000
  coef = 10
  odds.each do |o|
    if is_hit_wide?(box,o[:horse_number])
      wide_money += (o[:odds]*coef).round()
    end
  end
  wide_money
end

def is_hit_wide?(box,horse_nums)
  num1 = horse_nums.split(",")[0]
  num2 = horse_nums.split(",")[1]
  box.include?(num1) && box.include?(num2)
end

performance()
