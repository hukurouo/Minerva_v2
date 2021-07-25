# 定数
@jockey_coef = 0
@stallion_coef = 0
@trainer_coef = 0
@timepoint_coef = 0
@rank_coef = 0
@oikiri_coef = 0
@comment_coef = 0
@padoc_coef = 0
@framepoint_coef = 0
@kyakupoint_coef = 0
@tyakusapoint_coef = 0

def update
  system("ruby eval_padoc_finish.rb #{@jockey_coef} #{@stallion_coef} #{@trainer_coef} #{@timepoint_coef} #{@rank_coef} #{@oikiri_coef} #{@comment_coef} #{@padoc_coef} #{@framepoint_coef} #{@kyakupoint_coef} #{@tyakusapoint_coef}")
end

def auto
  [0.0,0.5,1.0].each do |i|
    [0.0,0.5,1.0].each do |j|
      [0.0,0.5,1.0].each do |k|
        [0.0,0.5,1.0].each do |l|
          [0.0,0.5,1.0].each do |m|
            [0.0,0.5,1.0].each do |n|
              [0.0,0.5,1.0].each do |o|
                [0.0,0.5,1.0].each do |pp|
                  [0.0,0.5,1.0].each do |q|
                    [0.0,0.5,1.0].each do |r|
                      #[0.0,0.3,0.6,1.0].each do |s|
                        @jockey_coef = i
                        @stallion_coef = j
                        @trainer_coef = k
                        @timepoint_coef = l
                        @rank_coef = m
                        @oikiri_coef = n
                        @comment_coef = o
                        @padoc_coef = pp
                        @framepoint_coef = q
                        @kyakupoint_coef = r
                        @tyakusapoint_coef = 0.5
                        update()
                      #end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

auto()