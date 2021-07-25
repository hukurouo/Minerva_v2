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

def write(race_result, place)
  CSV.open("datas/2020/#{place}/oikiri_comment.csv", "a") do |csv| 
    csv << race_result
  end
end

def main 
  agent = login()
  year = "2020"
  (1..10).each do |i|
    place =  format("%02<number>d", number: i)
    CSV.open("datas/2020/#{place}/oikiri_comment.csv", "w") do |csv| 
      csv << "id,horseId,oikiri,comment".split(",")
    end
    race_index = CSV.table("datas/2020/#{place}/index_fixed.csv", {:encoding => 'UTF-8', :converters => nil})
    race_index.each_with_index do |race, index|
      oikiri_map = get_oikiri(race[:id], agent)
      comment_map = get_comment(race[:id], agent)
      oikiri_map.each do |key,value|
        csv_row = [race[:id], key, value, comment_map[key]]
        write(csv_row, place)
      end
      p race[:id]
      sleep 1
    end
  end
  
end

main()