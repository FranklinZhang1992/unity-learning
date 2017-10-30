require 'set'
require 'json'

$answers = []

def mockup
    answer = Answer.new("华东大区", "上海", "莲花")
    $answers << answer
    answer = Answer.new("华东大区", "上海", "石库门")
    $answers << answer
    answer = Answer.new("华中大区", "北京", "京东")
    $answers << answer
    answer = Answer.new("华中大区", "天津", "广玉兰")
    $answers << answer
    answer = Answer.new("华南大区", "深圳", "天猫")
    $answers << answer
    answer = Answer.new("港澳大区", "香港", "迪士尼")
    $answers << answer
end

class Answer

    attr :area, :city, :store

    def initialize(area, city, store)
        @area = area
        @city = city
        @store = store
    end
end

class ObjBase

    attr :name
end

class Area < ObjBase

    def initialize(area_name, city)
        @name = area_name
        @cities = [city]
    end

    def push(city)
        @cities << city
    end

    def to_hash
        area_hash = Hash.new
        city_array = []
        @cities.each do |city|
            city_array << city.to_hash
        end
        area_hash[:name] = @name
        area_hash[:cities] = city_array
        area_hash
    end
end

class City < ObjBase

    attr :area

    def initialize(city_name, store, area)
        @name = city_name
        @stores = [store]
        @area = area
    end

    def push(store)
        @stores << store
    end

    def to_hash
        city_hash = Hash.new
        store_array = []
        @stores.each do |store|
            store_hash = Hash.new
            store_hash[:name] = store
            store_array << store_hash
        end
        city_hash[:name] = @name
        city_hash[:stores] = store_array
        city_hash
    end
end

class Result

    def initialize(areas)
        @areas = areas
    end

    def to_json
        json_hash = Hash.new
        area_array = []
        @areas.each_value do |area|
            area_array << area.to_hash
        end
        json_hash[:areas] = area_array
        JSON.generate(json_hash)
    end
end

begin
    mockup
    cities = Hash.new
    $answers.each do |answer|
        city = answer.city
        if cities[city].nil?
            cities[city] = City.new(city, answer.store, answer.area)
        else
            cities[city].push(answer.store)
        end
    end

    areas = Hash.new
    cities.each_value do |city|
        area = city.area
        if areas[area].nil?
            areas[area] = Area.new(area, city)
        else
            areas[area].push(city)
        end
    end

    result = Result.new(areas)
    puts result.to_json
rescue Exception => e
    raise
end
