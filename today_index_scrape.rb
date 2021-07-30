require 'fileutils'
require 'nokogiri'
require 'open-uri'
require "csv"
require 'mechanize'
require 'dotenv'
Dotenv.load

@race_id_pre = ["2021040303","2021020109"]
@dir_name = "202107"
@dir_name_2 = "20210731"

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

def get_data_logined_page(id,agent)
  url = "https://race.netkeiba.com/race/shutuba.html?race_id=#{id}&rf=race_submenu/"
  page = agent.get(url)
  name = page.xpath('//div[@class="RaceName"]').text.strip.gsub(/[[:space:]]/, '')
  race_info = page.xpath('//div[@class="RaceData01"]').css('span')[0].text.strip.gsub(/[[:space:]]/, '')
  race_type = race_info[0]
  race_length = race_info.delete("^0-9")
  place = id[4..5]
  race_info_csv = [id, name, place, race_type, race_length]
  CSV.open("today/#{@dir_name}/#{@dir_name_2}/index.csv", "a") do |csv| 
    csv << race_info_csv
  end
  
end

def main 
  agent = login()
  race_ids = []
  CSV.open("today/#{@dir_name}/#{@dir_name_2}/index.csv", "w") do |csv| 
    csv << "id,name,place,courseType,courseLength".split(",")
  end
  @race_id_pre.each do |pre|
    (1..12).each do |i|
      race_id = pre + format("%02<number>d", number: i)
      race_ids << race_id
    end
  end

  race_ids.each do |race_id|
    get_data_logined_page(race_id,agent)
    sleep 1
  end
end

main()