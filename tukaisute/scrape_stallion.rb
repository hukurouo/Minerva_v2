require "csv"
require 'mechanize'
require 'dotenv'
Dotenv.load

#FileUtils.mkdir_p('datas/2019', :mode => 755)

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

def get_data_logined_page(id, agent)
  url = "https://db.netkeiba.com/horse/#{id}/"
  page = agent.get(url)
  table = page.xpath('//table[@class="blood_table"]/tr')
  sta_id = table[0].css('td')[0].text.strip
  sta_name = table[0].css('td')[0].css('a')[0][:href].split("/")[3]
  return [sta_id, sta_name]
end

def write(race_result)
  CSV.open("intermediate/stallion/horse_stallion_index.csv", "a") do |csv| 
    csv << race_result
  end
end

def main 
  agent = login()
  horse_index = CSV.table("intermediate/horse/horse_index.csv", {:encoding => 'UTF-8', :converters => nil})
  horse_index.each_with_index do |horse, index|
    arr = get_data_logined_page(horse[:id], agent)
    result = [horse[:id], horse[:name], arr[0], arr[1]]
    write(result)
    sleep 1
  end
end

main()