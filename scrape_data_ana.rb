require 'fileutils'
require 'nokogiri'
require 'open-uri'
require "csv"
require 'mechanize'
require 'dotenv'
Dotenv.load

@place = "10"

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

def get_result(id,agent)
  url = "https://race.netkeiba.com/race/shutuba_past.html?race_id=#{id}&rf=shutuba_submenu"
  page = agent.get(url)
  map = {}
  table = page.xpath('//table[@id="sort_table"]/tbody/tr')
  table.each_with_index do |tr, index|
    ranks = []
    tyakusas = []
    horse_id = tr.css('td')[3].css('a')[0][:href].split("/")[4]
    horse_name = ""
    horse_number = ""
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
      
      horse_number = tr.css('td')[1].text.encode("UTF-16BE", "UTF-8",
        invalid: :replace,
        undef: :replace,
        replace: '-').encode("UTF-8").strip
      horse_name =tr.css('td')[3].css('a')[0].text.encode("UTF-16BE", "UTF-8",
        invalid: :replace,
        undef: :replace,
        replace: '-').encode("UTF-8").strip
      ranks << rank.to_f
      tyakusas << tyakusa.to_f
    end
    rank_sum = 0
    rank_sum =  (ranks.sum / ranks.length) if ranks.length != 0
    tyakusa_sum = 0
    tyakusa_sum =  (tyakusas.sum / tyakusas.length) if tyakusas.length != 0
    map[horse_id] = {rank: rank_sum.round(3), tyakusa: tyakusa_sum.round(3), name: horse_name, horse_number: horse_number}
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
    horse_number = t.css('td')[1].text.strip
    horse_id = t.css('td')[3].css('a')[0][:href].split("/")[4]
    oikiri_map[horse_id] = {score: score, horse_number: horse_number}
  end
  oikiri_map
end

def get_jockey(id, agent)
  url = "https://race.netkeiba.com/race/data_list.html?race_id=#{id}&mode=courseanalysis&cid=2#race_data__menu"
  page = agent.get(url)
  table = page.xpath('//table[@id="table_sort_back"]/tbody/tr')
  jockey_map = {}
  table.each_with_index do |t,i| 
    tan_score = t.css('td')[8].text.strip.split("%")[0]
    fuku_score = t.css('td')[10].text.strip.split("%")[0]
    total = t.css('td')[7].text.strip.split("%")[0]
    horse_id = t.css('td')[13].css('a')[0][:href].split("/")[4]
    jockey_map[horse_id] = {tan: tan_score, fuku: fuku_score, total: total}
  end
  jockey_map
end

def get_trainer(id, agent)
  url = "https://race.netkeiba.com/race/data_list.html?race_id=#{id}&mode=courseanalysis&cid=3#race_data__menu"
  page = agent.get(url)
  table = page.xpath('//table[@id="table_sort_back"]/tbody/tr')
  map = {}
  table.each_with_index do |t,i| 
    tan_score = t.css('td')[8].text.strip.split("%")[0]
    fuku_score = t.css('td')[10].text.strip.split("%")[0]
    total = t.css('td')[7].text.strip.split("%")[0]
    horse_id = t.css('td')[13].css('a')[0][:href].split("/")[4]
    map[horse_id] = {tan: tan_score, fuku: fuku_score, total: total}
  end
  map
end

def get_stallion(id, agent)
  url = "https://race.netkeiba.com/race/data_list.html?race_id=#{id}&mode=coursedata&cid=1#race_data__menu"
  page = agent.get(url)
  table = page.xpath('//table[@id="table_sort_back"]/tbody/tr')
  map = {}
  table.each_with_index do |t,i| 
    tan_score = t.css('td')[8].text.strip.split("%")[0]
    fuku_score = t.css('td')[10].text.strip.split("%")[0]
    total = t.css('td')[7].text.strip.split("%")[0]
    horse_id = t.css('td')[13].css('a')[0][:href].split("/")[4]
    map[horse_id] = {tan: tan_score, fuku: fuku_score, total: total}
  end
  map
end

def get_frame(id, agent)
  url = "https://race.netkeiba.com/race/data_list.html?race_id=#{id}&mode=courseanalysis&cid=0#race_data__menu"
  page = agent.get(url)
  table = page.xpath('//table[@id="table_sort_back"]/tbody/tr')
  map = {}
  table.each_with_index do |t,i| 
    tan_score = t.css('td')[8].text.strip.split("%")[0]
    fuku_score = t.css('td')[10].text.strip.split("%")[0]
    total = t.css('td')[7].text.strip.split("%")[0]
    horse_id = t.css('td')[13].css('a')[0][:href].split("/")[4]
    map[horse_id] = {tan: tan_score, fuku: fuku_score, total: total}
  end
  map
end

def get_kyaku(id, agent)
  url = "https://race.netkeiba.com/race/data_list.html?race_id=#{id}&mode=courseanalysis&cid=1#race_data__menu"
  page = agent.get(url)
  table = page.xpath('//table[@id="table_sort_back"]/tbody/tr')
  map = {}
  table.each_with_index do |t,i| 
    tan_score = t.css('td')[8].text.strip.split("%")[0]
    fuku_score = t.css('td')[10].text.strip.split("%")[0]
    total = t.css('td')[7].text.strip.split("%")[0]
    horse_id = t.css('td')[13].css('a')[0][:href].split("/")[4]
    map[horse_id] = {tan: tan_score, fuku: fuku_score, total: total}
  end
  map
end

def get_time(id, agent)
  url = "https://race.netkeiba.com/race/surf_summary.html?race_id=#{id}&range=4&key1=SpeedIdxScore#race_data__menu"
  page = agent.get(url)
  table = page.xpath('//table[@id="table_sort_back"]/tbody/tr')
  map = {}
  table.each_with_index do |t,i| 
    tan_score = t.css('td')[8].text.strip.split("%")[0]
    fuku_score = t.css('td')[10].text.strip.split("%")[0]
    total = t.css('td')[7].text.strip.split("%")[0]
    horse_id = t.css('td')[13].css('a')[0][:href].split("/")[4]
    tan_score = "0" if tan_score == "-"
    fuku_score = "0" if fuku_score == "-"
    total = "0" if total == "-"
    map[horse_id] = {tan: tan_score, fuku: fuku_score, total: total}
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

def today()
  agent = login()
  race_ids = []
  
  race_index = CSV.table("intermediate/datas/#{@place}/index.csv", {:encoding => 'UTF-8', :converters => nil})
  race_index.each do |r|
    race_ids << r[:id]
  end
  race_ids.each_with_index do |id, index|
    result_map = get_result(id, agent)
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
    frame_map = get_frame(id, agent)
    sleep 1
    kyaku_map = get_kyaku(id, agent)
    sleep 1
    time_map = get_time(id, agent)
    sleep 1
  
    result = []
    time_map.each do |key,value|
      #id,horseId,jockeyPoint,stallionPoint,trainerPoint,timePoint,resultPoint,timeDiffPoint,oikiri,comment,padoc,rank,framePoint,kyakuPoint,timePoint,rankPoint,tyakusaPoint
      csv_row = [
        id,
        key,
        oikiri_map[key][:horse_number],
        jockey_map[key][:tan],
        jockey_map[key][:fuku],
        jockey_map[key][:total],
        stallion_map[key][:tan],
        stallion_map[key][:fuku],
        stallion_map[key][:total],
        trainer_map[key][:tan],
        trainer_map[key][:fuku],
        trainer_map[key][:total],
        frame_map[key][:tan],
        frame_map[key][:fuku],
        frame_map[key][:total],
        kyaku_map[key][:tan],
        kyaku_map[key][:fuku],
        kyaku_map[key][:total],
        oikiri_num(oikiri_map[key][:score]),
        comment_num(comment_map[key]),
        value[:tan],
        value[:fuku],
        value[:total],
        result_map[key][:rank],
        result_map[key][:tyakusa],
      ]
      result << csv_row
    end
    write(result, @place)
    p id
  end
end

def write(race_results, place)
  CSV.open("intermediate/datas/#{place}/raw_datas.csv", "a") do |csv| 
    race_results.each do |data|
      csv << data
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

today()