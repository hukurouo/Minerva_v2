require "csv"

@dir_name = "202107"
@file_name = "20210725"

def normalize_datas
  raw_datas = CSV.table("today/#{@dir_name}/#{@file_name}/datas.csv", {:encoding => 'UTF-8', :converters => nil})
  #id,horseId,horseNumber
  id = raw_datas[0][:id]
  raw_data_unit = {
    id: [],
    horseId: [],
    horseNumber: [],
    jockey: [],
    stallion: [],
    trainer: [],
    frame: [],
    kyaku: [],
    oikiri: [],
    comment: [],
    time: [],
    rank: [],
    tyakusa: []
  }
  n_datas = []
  raw_datas.each do |raw_data|
    #write
    if raw_data[:id] != id
      n_data_unit = {}
      raw_data_unit.each do |key,value|
        n_data_unit[key] = value; next if key == :id
        n_data_unit[key] = value; next if key == :horseId
        n_data_unit[key] = value; next if key == :horseNumber
        max_num = value.max
        div_num = max_num / 5
        div_num = 1 if div_num == 0
        n_data_unit[key] = value.map{|x|(x/div_num).round(2)}
      end
      col_nums = n_data_unit[:time].size
      (0..col_nums-1).each do |index|
        n_datas_row = []
        n_data_unit.each do |key,value|
          n_datas_row << value[index]
        end
        n_datas << n_datas_row
      end
      
      #init
      id = raw_data[:id]
      raw_data_unit = {
        id: [],
        horseId: [],
        horseNumber: [],
        jockey: [],
        stallion: [],
        trainer: [],
        frame: [],
        kyaku: [],
        oikiri: [],
        comment: [],
        time: [],
        rank: [],
        tyakusa: []
      }
    end
    #update
    raw_data_unit[:id] << raw_data[:id]
    raw_data_unit[:horseId] << raw_data[:horseid]
    raw_data_unit[:horseNumber] << raw_data[:horsenumber]
    raw_data_unit[:jockey] << raw_data[:jockeypointtop].to_f
    raw_data_unit[:stallion] << raw_data[:stallionpointtop].to_f
    raw_data_unit[:trainer] << raw_data[:trainerpointtop].to_f
    raw_data_unit[:frame] << raw_data[:framepointtop].to_f
    raw_data_unit[:kyaku] << raw_data[:kyakupointtop].to_f
    raw_data_unit[:oikiri] << raw_data[:oikiri].to_f
    raw_data_unit[:comment] << raw_data[:comment].to_f
    raw_data_unit[:time] << raw_data[:timepointtop].to_f
    raw_data_unit[:rank] << raw_data[:rankpoint].to_f
    raw_data_unit[:tyakusa] << raw_data[:tyakusapoint].to_f
  end
  n_data_unit = {}
  raw_data_unit.each do |key,value|
    n_data_unit[key] = value; next if key == :id
    n_data_unit[key] = value; next if key == :horseId
    n_data_unit[key] = value; next if key == :horseNumber
    max_num = value.max
    div_num = max_num / 5
    div_num = 1 if div_num == 0
    n_data_unit[key] = value.map{|x|(x/div_num).round(2)}
  end
  col_nums = n_data_unit[:time].size
  (0..col_nums-1).each do |index|
    n_datas_row = []
    n_data_unit.each do |key,value|
      n_datas_row << value[index]
    end
    n_datas << n_datas_row
  end

  
  CSV.open("today/#{@dir_name}/#{@file_name}/n_datas.csv", "w") do |csv| 
    n_datas.each do |data|
      csv << data
    end
  end
end

normalize_datas()