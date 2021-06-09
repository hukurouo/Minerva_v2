require "csv"

def checkOdds
  (1..10).each do |i|
    place =  format("%02<number>d", number: i)
    odds = CSV.table("datas/2020/#{place}/odds.csv", {:encoding => 'UTF-8', :converters => nil})
    odds.each do |odd|
      if odd[:odds].to_i > 100000 && odd[:type] == "単勝"
        p odd[:id]
      end
    end
  end
end

checkOdds()