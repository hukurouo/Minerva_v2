require 'fileutils'
require 'nokogiri'
require 'open-uri'
require "csv"
require 'mechanize'
require 'dotenv'
Dotenv.load

@result_header = "id,raceName,rank,frameNumber,horseNumber,horseName,horseId,sexAge,weight,jockeyName,time,timeDiff,timePoint,passingOrder,time3f,oddsNum,oddsRank,horseWeight,horseWeightDiff,memo".split(",")

def login
  agent = Mechanize.new
  login_page = agent.get("https://regist.netkeiba.com/account/?pid=login")

  form = login_page.forms[1]
  button = form.buttons
  form["login_id"] = ENV["ID"]
  form["pswd"] = ENV["PASS"]

  form.submit()
  agent
end

def get_rank(id,agent)
  url = "https://db.netkeiba.com/race/#{id}/"
  page = agent.get(url)
  table = page.xpath('//table[@class="race_table_01 nk_tb_common"]/tr')
  map = {}
  table.each_with_index do |tr, index|
    next if index == 0
    rank = tr.css('td')[0].text.encode("UTF-16BE", "UTF-8",
      invalid: :replace,
      undef: :replace,
      replace: '-').encode("UTF-8")
    horse_number = tr.css('td')[2].text.encode("UTF-16BE", "UTF-8",
      invalid: :replace,
      undef: :replace,
      replace: '-').encode("UTF-8")
    rank_odds = tr.css('td')[12].text.encode("UTF-16BE", "UTF-8",
      invalid: :replace,
      undef: :replace,
      replace: '-').encode("UTF-8")
    horse_id = tr.css('td')[3].css('a')[0][:href].split("/")[2]
    map[horse_id] = {rank: rank, horse_number: horse_number, rank_odds: rank_odds}
  end
  map
end

def get_result(id,agent)
  url = "https://race.netkeiba.com/race/shutuba_past.html?race_id=#{id}&rf=shutuba_submenu"
  page = agent.get(url)
  map = {}
  table = page.xpath('//table[@id="sort_table"]/tbody/tr')
  table.each_with_index do |tr, index|
    ranks = []
    tyakusas = []
    horse_id = ""
    horse_name = ""
    (5..9).each do |i|
      next unless tr.css('td')[i].css('div')[0]
      next unless tr.css('td')[i].css('div')[0].css('div')[0]
      next unless tr.css('td')[i].css('div')[6]
      rank = tr.css('td')[i].css('div')[0].css('div')[0].css('span')[1].text.encode("UTF-16BE", "UTF-8",
        invalid: :replace,
        undef: :replace,
        replace: '-').encode("UTF-8")
      next unless rank.match?(/\d/)
      tyakusa = tr.css('td')[i].css('div')[6].text.encode("UTF-16BE", "UTF-8",
        invalid: :replace,
        undef: :replace,
        replace: '-').encode("UTF-8").split("(")[1].split(")")[0]
      horse_id = tr.css('td')[3].css('a')[0][:href].split("/")[4]
      ranks << rank.to_f
      tyakusas << tyakusa.to_f
    end
    rank_sum = 0
    rank_sum =  (ranks.sum / ranks.length) if ranks.length != 0
    tyakusa_sum = 0
    tyakusa_sum =  (tyakusas.sum / tyakusas.length) if tyakusas.length != 0
    map[horse_id] = {rank: rank_sum.round(3), tyakusa: tyakusa_sum.round(3)}
  end
  map
end

def get_oikiri(id, agent)
  url = "https://race.netkeiba.com/race/oikiri.html?race_id=#{id}&rf=race_submenu"
  page = agent.get(url)
  table = page.xpath('//table[@id="All_Oikiri_Table"]/tr')
  oikiri_map = {}
  table.each_with_index do |t,i| 
    next if i == 0
    score = t.css('td')[12].text.strip
    horse_id = t.css('td')[3].css('a')[0][:href].split("/")[4]
    oikiri_map[horse_id] = score
  end
  oikiri_map
end

def get_jockey(id, agent)
  url = "https://race.netkeiba.com/race/data_list.html?race_id=#{id}&mode=courseanalysis&cid=2#race_data__menu"
  page = agent.get(url)
  table = page.xpath('//table[@id="table_sort_back"]/tbody/tr')
  jockey_map = {}
  table.each_with_index do |t,i| 
    score = t.css('td')[8].text.strip.split("%")[0]
    horse_id = t.css('td')[13].css('a')[0][:href].split("/")[4]
    jockey_map[horse_id] = score
  end
  jockey_map
end

def get_trainer(id, agent)
  url = "https://race.netkeiba.com/race/data_list.html?race_id=#{id}&mode=courseanalysis&cid=3#race_data__menu"
  page = agent.get(url)
  table = page.xpath('//table[@id="table_sort_back"]/tbody/tr')
  map = {}
  table.each_with_index do |t,i| 
    score = t.css('td')[8].text.strip.split("%")[0]
    horse_id = t.css('td')[13].css('a')[0][:href].split("/")[4]
    map[horse_id] = score
  end
  map
end

def get_stallion(id, agent)
  url = "https://race.netkeiba.com/race/data_list.html?race_id=#{id}&mode=coursedata&cid=1#race_data__menu"
  page = agent.get(url)
  table = page.xpath('//table[@id="table_sort_back"]/tbody/tr')
  map = {}
  table.each_with_index do |t,i| 
    score = t.css('td')[8].text.strip.split("%")[0]
    horse_id = t.css('td')[13].css('a')[0][:href].split("/")[4]
    map[horse_id] = score
  end
  map
end

def get_frame(id, agent)
  url = "https://race.netkeiba.com/race/data_list.html?race_id=#{id}&mode=courseanalysis&cid=0#race_data__menu"
  page = agent.get(url)
  table = page.xpath('//table[@id="table_sort_back"]/tbody/tr')
  map = {}
  table.each_with_index do |t,i| 
    score = t.css('td')[8].text.strip.split("%")[0]
    horse_id = t.css('td')[13].css('a')[0][:href].split("/")[4]
    map[horse_id] = score
  end
  map
end

def get_kyaku(id, agent)
  url = "https://race.netkeiba.com/race/data_list.html?race_id=#{id}&mode=courseanalysis&cid=1#race_data__menu"
  page = agent.get(url)
  table = page.xpath('//table[@id="table_sort_back"]/tbody/tr')
  map = {}
  table.each_with_index do |t,i| 
    score = t.css('td')[8].text.strip.split("%")[0]
    horse_id = t.css('td')[13].css('a')[0][:href].split("/")[4]
    map[horse_id] = score
  end
  map
end

def get_time(id, agent)
  url = "https://race.netkeiba.com/race/surf_summary.html?race_id=#{id}&range=4&key1=SpeedIdxScore#race_data__menu"
  page = agent.get(url)
  table = page.xpath('//table[@id="table_sort_back"]/tbody/tr')
  map = {}
  table.each_with_index do |t,i| 
    score = t.css('td')[8].text.strip.split("%")[0]
    horse_id = t.css('td')[13].css('a')[0][:href].split("/")[4]
    score = "0" if score == "-"
    map[horse_id] = score
  end
  map
end

def get_padoc(id, agent)
  url = "https://race.netkeiba.com/race/paddock.html?race_id=#{id}&rf=shutuba_submenu"
  page = agent.get(url)
  table = page.xpath('//table[@class="Paddock_Table race_table_01"]/tbody/tr')
  map = {}
  table.each_with_index do |t,i| 
    horse_id = t.css('td')[2].css('a')[0][:href].split("/")[4]
    map[horse_id] = 1
  end
  map
end

def get_comment(id, agent)
  url = "https://race.netkeiba.com/race/comment.html?race_id=#{id}&rf=race_submenu"
  agent.default_encoding = 'utf-8'
  agent.force_default_encoding = true
  page = agent.get(url)
  table = page.xpath('//table[@id="All_Comment_Table"]/tbody/tr')
  comment_map = {}
  table.each_with_index do |t,i| 
    next if i == 0
    next unless t
    next unless t.css('td')[4]
    score = t.css('td')[4].css('span').attr('class').value.slice(-2,2)
    horse_id = t.css('td')[2].css('a')[0][:href].split("/")[4]
    comment_map[horse_id] = score
  end
  comment_map
end

def write(race_result)
  CSV.open("today/2021/valid-padoc-train-data-tan.csv", "a") do |csv| 
    race_result.each do |result|
      csv << result
    end
  end
end

def main 
  agent = login()
  race_ids = CSV.table("today/2021/valid-padoc-race-index.csv", {:encoding => 'UTF-8', :converters => nil})
  race_ids.each do |r|
    id = r[:raceid]
    rank_map = get_rank(id,agent)
    sleep 1
    oikiri_map = get_oikiri(id, agent)
    sleep 1
    comment_map = get_comment(id, agent)
    sleep 1
    jockey_map = get_jockey(id, agent)
    sleep 1
    trainer_map = get_trainer(id, agent)
    sleep 1
    stallion_map = get_stallion(id, agent)
    sleep 1
    padoc_map = get_padoc(id, agent)
    sleep 1
    frame_map = get_frame(id, agent)
    sleep 1
    kyaku_map = get_kyaku(id, agent)
    sleep 1
    time_map = get_time(id, agent)
    sleep 1
    result_map = get_result(id,agent)
    sleep 1
    result = []
    frame_map.each do |key,value|
      csv_row = [
        id,
        key,
        jockey_map[key],
        stallion_map[key],
        trainer_map[key],
        oikiri_num(oikiri_map[key]),
        comment_num(comment_map[key]),
        padoc_map[key] || 0,
        value,
        kyaku_map[key],
        time_map[key],
        result_map[key][:rank],
        result_map[key][:tyakusa],
        rank_map[key][:rank],
        rank_map[key][:rank_odds],
        rank_map[key][:horse_number],
      ]
      result << csv_row
    end
    write(result)
    p id
  end
end

def today()
  agent = login()
  race_ids = ["202105030712"]
  race_ids.each_with_index do |id, index|
    result_map = get_result(id,agent)
    sleep 1
    oikiri_map = get_oikiri(id, agent)
    sleep 1
    comment_map = get_comment(id, agent)
    sleep 1
    jockey_map = get_jockey(id, agent)
    sleep 1
    trainer_map = get_trainer(id, agent)
    sleep 1
    stallion_map = get_stallion(id, agent)
    sleep 1
    padoc_map = get_padoc(id, agent)
    sleep 1
    frame_map = get_frame(id, agent)
    sleep 1
    kyaku_map = get_kyaku(id, agent)
    sleep 1
    time_map = get_time(id, agent)
    sleep 1
    
    result = ["id,horseId,jockeyPoint,stallionPoint,trainerPoint,timePoint,resultPoint,timeDiffPoint,oikiri,comment,padoc,rank,framePoint,kyakuPoint,timePoint,rankPoint,tyakusaPoint,horseName".split(",")]
    frame_map.each do |key,value|
      #id,horseId,jockeyPoint,stallionPoint,trainerPoint,timePoint,resultPoint,timeDiffPoint,oikiri,comment,padoc,rank,framePoint,kyakuPoint,timePoint,rankPoint,tyakusaPoint
      csv_row = [
        id,
        key,
        jockey_map[key],
        stallion_map[key],
        trainer_map[key],
        0,
        0,
        0,
        oikiri_num(oikiri_map[key]),
        comment_num(comment_map[key]),
        padoc_map[key] || 0,
        0,
        value,
        kyaku_map[key],
        time_map[key],
        result_map[key][:rank],
        result_map[key][:tyakusa],
        result_map[key][:name],
      ]
      result << csv_row
    end
    write_today(result,id)
  end
end

def write_today(race_result,id)
  CSV.open("today/2021/6/#{id}.csv", "w") do |csv| 
    race_result.each do |result|
      csv << result
    end
  end
end

def odds_scrape()
  agent = login()
  race_ids = CSV.table("today/2021/valid-padoc-race-index.csv", {:encoding => 'UTF-8', :converters => nil})
  original_map = {}
  original_data = CSV.table("today/2021/valid-padoc-train-data-add.csv", {:encoding => 'UTF-8', :converters => nil})
  original_data.each do |o|
    if original_map[o[:id]]
      original_map[o[:id]][o[:horseid]] = o
    else
      original_map[o[:id]] = {}
      original_map[o[:id]][o[:horseid]] = o
    end
  end
  race_ids.each do |r|
    id = r[:raceid]
    url = "https://db.netkeiba.com/race/#{id}/"
    page = agent.get(url)
    sleep 1
    table = page.xpath('//table[@class="race_table_01 nk_tb_common"]/tr')
    map = {}
    result = []
    table.each_with_index do |tr, index|
      next if index == 0
      odds_rank = tr.css('td')[12].text.strip
      horse_id = tr.css('td')[3].css('a')[0][:href].split("/")[2]
      map[horse_id] = odds_rank
    end
    map.each do |key,value|
      next unless original_map[id][key]
      csv_row = original_map[id][key]
      csv_row << value
      result << csv_row
    end
    write_add_odds_rank(result)
    results = get_odds(page, id)
    CSV.open("today/2021/valid-padoc-odds.csv", "a") do |csv| 
      results.each do |data|
        csv << data
      end
    end
  end
end

def write_add_odds_rank(race_result)
  CSV.open("today/2021/valid-padoc-train-data-add2.csv", "a") do |csv| 
    race_result.each do |result|
      csv << result
    end
  end
end

def oikiri_num(rank)
  oikiri_point = 0
  oikiri_point = 20 if rank == "B"
  oikiri_point = 40 if rank == "A"
  oikiri_point
end

def comment_num(rank)
  comment_point = 0
  comment_point = 20 if rank == "02"
  comment_point = 40 if rank == "01"
  comment_point
end

def get_odds(doc,id)
  table = doc.xpath('//table[@class="pay_table_01"]/tr')
  results = []

  # 単勝
  tan_table = table.select{|t|t.css('th').text == "単勝"}.first
  if tan_table
    if tan_table.css('td')[0].children.length > 1
      tan_nums = tan_table.css('td')[0].children.map{|c|c.text}
      tan_odds = tan_table.css('td')[1].children.map{|c|c.text.gsub(/,/,"").to_i}
      results << [id, "単勝", tan_nums[0].to_s, tan_odds[0]]
      results << [id, "単勝", tan_nums[2].to_s, tan_odds[2]]
    else
      tan_num = tan_table.css('td')[0].text
      tan_odds = tan_table.css('td')[1].text.gsub(/,/,"").to_i
      results << [id, "単勝", tan_num.to_s, tan_odds]
    end
  end
  
  # 複勝
  huku_table = table.select{|t|t.css('th').text == "複勝"}.first
  if huku_table
    huku_nums = huku_table.css('td')[0].children.map{|c|c.text}
    huku_odds = huku_table.css('td')[1].children.map{|c|c.text}
    huku_nums.delete("")
    huku_odds.delete("")
    (0..huku_nums.length-1).each do |i|
      results << [id, "複勝", huku_nums[i], huku_odds[i].gsub(/,/,"").to_i]
    end
  end

  # 枠連
  wakuren_table = table.select{|t|t.css('th').text == "枠連"}.first
  if wakuren_table
    tan_num = wakuren_table.css('td')[0].text.gsub(/ - /,",")
    tan_odds = wakuren_table.css('td')[1].text.gsub(/,/,"").to_i
    results << [id, "枠連", tan_num, tan_odds]
  end

  # 馬連
  umaren_table = table.select{|t|t.css('th').text == "馬連"}.first
  if umaren_table
    tan_num = umaren_table.css('td')[0].text.gsub(/ - /,",")
    tan_odds = umaren_table.css('td')[1].text.gsub(/,/,"").to_i
    results << [id, "馬連", tan_num, tan_odds]
  end

  # ワイド
  wide_table = table.select{|t|t.css('th').text == "ワイド"}.first
  if wide_table
    huku_nums = wide_table.css('td')[0].children.map{|c|c.text}
    huku_odds = wide_table.css('td')[1].children.map{|c|c.text}
    huku_nums.delete("")
    huku_odds.delete("")
    (0..huku_nums.length-1).each do |i|
      results << [id, "ワイド", huku_nums[i].gsub(/ - /,","), huku_odds[i].gsub(/,/,"").to_i]
    end
  end

  # 馬単
  umatan_table = table.select{|t|t.css('th').text == "馬単"}.first
  if umatan_table
    tan_num = umatan_table.css('td')[0].text.gsub(/ → /,",")
    if tan_num.count(',') == 2
      tan_nums = umatan_table.css('td')[0].children.map{|c|c.text.gsub(/ → /,",")}
      tan_odds = umatan_table.css('td')[1].children.map{|c|c.text.gsub(/,/,"").to_i}
      tan_nums.delete("")
      tan_odds.delete("")
      results << [id, "馬単", tan_nums[0], tan_odds[0]]
      results << [id, "馬単", tan_nums[1], tan_odds[2]]
    else
      tan_odds = umatan_table.css('td')[1].text.gsub(/,/,"").to_i
      results << [id, "馬単", tan_num, tan_odds]
    end
  end

  # 三連複
  renhuku_table = table.select{|t|t.css('th').text == "三連複"}.first
  if renhuku_table
    tan_num = renhuku_table.css('td')[0].text.gsub(/ - /,",")
    tan_odds = renhuku_table.css('td')[1].text.gsub(/,/,"").to_i
    results << [id, "三連複", tan_num, tan_odds]
  end

  # 三連単
  rentan_table = table.select{|t|t.css('th').text == "三連単"}.first
  if rentan_table
    tan_num = rentan_table.css('td')[0].text.gsub(/ → /,",")
    if tan_num.count(',') == 4
      tan_nums = rentan_table.css('td')[0].children.map{|c|c.text.gsub(/ → /,",")}
      tan_odds = rentan_table.css('td')[1].children.map{|c|c.text.gsub(/,/,"").to_i}
      tan_nums.delete("")
      tan_odds.delete("")
      results << [id, "三連単", tan_nums[0], tan_odds[0]]
      results << [id, "三連単", tan_nums[1], tan_odds[2]]
    else
      tan_odds = rentan_table.css('td')[1].text.gsub(/,/,"").to_i
      results << [id, "三連単", tan_num, tan_odds]
    end
  end

  results
end


main()
#today()
#odds_scrape()