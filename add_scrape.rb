require 'fileutils'
require 'nokogiri'
require 'open-uri'
require "csv"
require 'mechanize'
require 'dotenv'
Dotenv.load

#FileUtils.mkdir_p('datas/2019', :mode => 755)

@result_header = "id,raceName,rank,frameNumber,horseNumber,horseName,horseId,sexAge,weight,jockeyName,time,timeDiff,timePoint,passingOrder,time3f,oddsNum,oddsRank,horseWeight,horseWeightDiff,memo,trainerId,arrangeTime,arrangeTimeDiff".split(",")

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

def get_data_logined_page(id,agent, year, place)
  url = "https://db.netkeiba.com/race/#{id}/"
  page = agent.get(url)
  table = page.xpath('//table[@class="race_table_01 nk_tb_common"]/tr')
  name = page.xpath('//div[@class="data_intro"]').css('h1').text.strip.gsub(/[[:space:]]/, '')
  return if name == ""
  race_info = page.xpath('//div[@class="data_intro"]').css('diary_snap_cut').text
  race_type = race_info[1]
  race_dir = race_info[2]
  race_length = race_info.split("/")[0].delete("^0-9")
  weather = race_info.split("/")[1].split(":")[1].strip.gsub(/[[:space:]]/, '')
  race_cond = race_info.split("/")[2].split(":")[1].strip.gsub(/[[:space:]]/, '')
  race_cond_num = page.xpath('//table[@class="result_table_02"]/tr')[0].css('td').text.strip.split(" ")[0]
  date = page.xpath('//p[@class="smalltxt"]').text.split(" ")[0].gsub(/年|月/,"/").gsub(/日/,"")
  race_info_csv = [id, name, race_type, race_dir, race_length, weather, race_cond, race_cond_num, date]
  CSV.open("datas/#{year}/#{place}/index_fixed.csv", "a") do |csv| 
    csv << race_info_csv
  end
  if year == "2021"
    results = get_odds(page, id)
    CSV.open("datas/#{year}/#{place}/odds.csv", "a") do |csv| 
      results.each do |data|
        csv << data
      end
    end
  end
  race_results = []
  table.each_with_index do |tr, index|
    next if index == 0
    tds = [id, name]
    tr.css('td').each_with_index do |td, index|
      if [0,1,2,4,5,7,8,9,10,11,12,13,17].include?(index)
        tds.push(td.text.strip)
      elsif index == 3
        tds.push(td.text.strip)
        tds.push(td.css('a')[0][:href].split("/")[2])
      elsif index == 6
        tds.push(td.text.strip)
        tds.push(td.css('a')[0][:href].split("/")[2])
      elsif index == 14
        if td.text.strip.include?("(") 
          tds.push(td.text.split("(")[0])
          tds.push(td.text.split("(")[1].split(")")[0].gsub(/\+/, ''))
        else
          tds.push(td.text.strip)
          tds.push(0)
        end     
      elsif index == 18
        tds.push(td.css('a')[0][:href].split("/")[2])
      end
    end
    race_results.push tds
  end
  write(race_results, year, place)
end


def write(race_results, year, place)
  CSV.open("datas/#{year}/#{place}/race_result.csv", "a") do |csv| 
    race_results.each do |data|
      csv << data
    end
  end
end

def main 
  agent = login()
  year = "2021"
  race_info = CSV.table("race_info.csv", {:encoding => 'UTF-8', :converters => nil})
  
  place = "02"
  kai = 1
  day = 8
  
  (1..12).each do |r|
    kai_s = format("%02<number>d", number: kai)
    day_s = format("%02<number>d", number: day)
    r_s =  format("%02<number>d", number: r)
    id = year + place + kai_s + day_s + r_s
    get_data_logined_page(id,agent, year, place)
    sleep 1
    p id
  end
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