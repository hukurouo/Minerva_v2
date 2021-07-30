require "csv"

@dir_name = "202107"
@file_name = "20210731"

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
    #total_adjust jockeyPointTotal
    jockey_total = raw_data[:jockeypointtotal].to_f
    stallion_total = raw_data[:stallionpointtotal].to_f
    trainer_total = raw_data[:trainerpointtotal].to_f
    frame_total = raw_data[:framepointtotal].to_f
    kyaku_total = raw_data[:kyakupointtotal].to_f
    time_total = raw_data[:timepointtotal].to_f

    raw_data_unit[:id] << raw_data[:id]
    raw_data_unit[:horseId] << raw_data[:horseid]
    raw_data_unit[:horseNumber] << raw_data[:horsenumber]
    raw_data_unit[:jockey] << total_adjust(raw_data[:jockeypointtop].to_f, jockey_total)
    raw_data_unit[:stallion] << total_adjust(raw_data[:stallionpointtop].to_f, stallion_total)
    raw_data_unit[:trainer] << total_adjust(raw_data[:trainerpointtop].to_f, trainer_total)
    raw_data_unit[:frame] << total_adjust(raw_data[:framepointtop].to_f, frame_total)
    raw_data_unit[:kyaku] << total_adjust(raw_data[:kyakupointtop].to_f, kyaku_total)
    raw_data_unit[:oikiri] << raw_data[:oikiri].to_f
    raw_data_unit[:comment] << raw_data[:comment].to_f
    raw_data_unit[:time] << total_adjust(raw_data[:timepointtop].to_f, time_total)
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

  
  CSV.open("today/#{@dir_name}/#{@file_name}/n_datas_ad.csv", "w") do |csv| 
    n_datas.each do |data|
      csv << data
    end
  end
end

def total_adjust(top, total)
  adjust_top = top
  adjust_top = top / 10 if total == 1
  adjust_top = top / 5 if total == 2
  adjust_top = top / 5 if total == 3
  adjust_top = top / 4 if total == 4
  adjust_top = top / 4 if total == 5
  adjust_top = top / 3 if total == 6
  adjust_top = top / 2 if total == 7
  adjust_top = top / 2 if total == 8
  adjust_top
end

normalize_datas()