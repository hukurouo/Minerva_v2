require "csv"

tmp_perf = CSV.table("output/sandbox_v5(17-20)/未勝利/tmp_perf.csv", {:encoding => 'UTF-8', :converters => nil})
#name,tan,wide,wide3,wide1point

map = {
  type0: 0,
  type170: 0,
  type190: 0,
  type210: 0,
  type230: 0,
  type250: 0,
  type270: 0,
}

tmp_perf.each do |t|
  point = t[:wide1point].to_f
  if point.between?(0,170)
    map[:type0] += t[:wide].to_f.round
  elsif point.between?(170,190)
    map[:type170] += t[:wide].to_f.round
  elsif point.between?(190,210)
    map[:type190] += t[:wide].to_f.round
  elsif point.between?(210,230)
    map[:type210] += t[:wide].to_f.round
  elsif point.between?(230,250)
    map[:type230] += t[:wide].to_f.round
  elsif point.between?(250,270)
    map[:type250] += t[:wide].to_f.round
  else
    map[:type270] += t[:wide].to_f.round
  end
end

p map