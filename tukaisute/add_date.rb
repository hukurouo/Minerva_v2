require 'fileutils'
require 'nokogiri'
require 'open-uri'
require "csv"
require 'mechanize'
require 'dotenv'
Dotenv.load

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
end

def main 
  agent = login()
  year = "2017"
  race_info = CSV.table("race_info.csv", {:encoding => 'UTF-8', :converters => nil})
  race_info.each_with_index do |race, index|
    place = race[:id]

    CSV.open("datas/#{year}/#{place}/index_fixed.csv", "w") do |csv| 
      csv << "id,raceName,courseType,courseDir,courseLength,weather,courseStatus,courseStatusNum,date".split(",")
    end
    index_csv = CSV.table("datas/#{year}/#{place}/index.csv", {:encoding => 'UTF-8', :converters => nil})
    index_csv.each do |index_c|
      id = index_c[:id]
      get_data_logined_page(id,agent, year, place)
      sleep 1
      p id
    end
  end
end

main()