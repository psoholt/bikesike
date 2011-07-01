#http://scrumy.com/nuke54tumbril
#require 'bysykkel'
require 'open-uri'
require 'rexml/document'
include REXML
require_relative "../models/bike_station"
require_relative "../models/bike_light"
class Execute
  public
  def Execute.web_open_all_xml()
    open("http://smartbikeportal.clearchannel.no/public/mobapp/maq.asmx/getRacks")
  end

  def Execute.web_open_xml(number)
    # open("http://www.adshel.no/js/getracknr.php?id="+number.to_s)
    open("http://smartbikeportal.clearchannel.no/public/mobapp/maq.asmx/getRack?id="+number.to_s)
  end

  def Execute.get_stativ_textxml_web (number)
    tekst = ""
    web_open_xml(number) do | web |
      web.each_line { |f| tekst+= f }
    end
    tekst
  end

  def Execute.get_all_xml(data)
    tekst = ""
    data = Execute.web_open_all_xml() if data.nil?
    data.each_line { |f| tekst+= f }
    tekst = tekst.gsub("&lt;", "<").gsub("&gt;", ">")
    Document.new(tekst)
  end

  def Execute.get_stativ_xml(data)
    tekst = ""
    data = Execute.web_open_xml(id) if data.nil?
    data.each_line { |f| tekst+= f }
    tekst = tekst.gsub("&lt;", "<").gsub("&gt;", ">")
    Document.new(tekst)
  end

  def Execute.get_bike_station_yield(id)
    Execute.initialize_bikestation_from_xml(Execute.get_stativ_xml(yield(id)) , id )
  end

  def Execute.get_bike_station(id, cache_helper = nil, use_updated_cache = true)
    if cache_helper.nil?
      return Execute.initialize_bikestation_from_xml(Execute.get_stativ_xml(Execute.web_open_xml(id)), id)
    end
    cached_bike = cache_helper.get(id, use_updated_cache)
    if(cached_bike.nil?)
      bike_station = Execute.initialize_bikestation_from_xml(Execute.get_stativ_xml(Execute.web_open_xml(id)), id)
      cached_bike = cache_helper.put(bike_station)
    end
    cached_bike
  end

  def Execute.get_all_stations(cache_helper = nil)
    bike_stations = []
    unless(cache_helper.nil?)
      bikehash = cache_helper.get_all
      #puts "bikehash" + bikehash.to_s
      bikehash.values.each { |x| bike_stations << x }
      #puts "values"+bike_stations.to_s
      #return bike_stations if bike_stations.count > 100
      return bike_stations if bike_stations.count > 100 || cache_helper.is_mock?
    end
    station_numbers = Execute.get_all_station_numbers cache_helper
    station_numbers.each {|x| bike_stations << Execute.get_bike_station(x, cache_helper, false) } #if x < 12 }
    bike_stations
  end

  def Execute.get_all_station_numbers(cache_helper = nil)
    unless(cache_helper.nil?)
      station_numbers = cache_helper.get_bike_ids
      return station_numbers if station_numbers.count > 100
    end
    Execute.initialize_bikestations_from_xml( Execute.get_all_xml(Execute.web_open_all_xml))
  end

  def Execute.get_all_within_area_updated(swlat, swlng, nelat, nelng, cache_helper = nil)
    stations_within_area = Execute.get_all_within_area swlat, swlng, nelat, nelng, cache_helper
    stations_within_area_updated = Array.new
    stations_within_area.each { |station| stations_within_area_updated << Execute.get_bike_station(station.id,cache_helper,true)}
    stations_within_area_updated
  end

  def Execute.get_all_within_area(swlat, swlng, nelat, nelng, cache_helper = nil)
    all_stations = Execute.get_all_stations cache_helper
    stations_within_area = Array.new
    all_stations.each do | station |
      bike_longitude = station.longitude.to_f
      #puts "long: "+ bike_longitude.to_s + ">" +swlng.to_s + " and "+ bike_longitude.to_s + "<" + nelng.to_s
      if bike_longitude > swlng and bike_longitude < nelng
        bike_latitude = station.latitude.to_f
        #puts "lat: "+bike_latitude.to_s + ">" +swlat.to_s + " and "+ bike_latitude.to_s + "<" + nelat.to_s
        if bike_latitude > swlat and bike_latitude < nelat
          #puts "true"
          stations_within_area << station
        end
      end
    end
    stations_within_area
  end

  def Execute.get_closest_sorted_stations(lat, lng, cache_helper = nil)
    all_stations = Execute.get_all_stations cache_helper
    stationHash = Hash.new()
    all_stations.each do | station |
      puts "kjorer igjennom"
       length = Math.sqrt((station.longitude.to_f-lng.to_f)**2+(station.latitude.to_f-lat.to_f)**2)
       puts length
       stationHash[length] = station
    end
    stationHash
  end

  def Execute.open_xml_from_file (number, relative_path = "./" )
    File.read(relative_path+"bikexmlexample"+number.to_s+".xml")
  end

  def Execute.get_stativ_textxml_from_file (number, relative_path)
    tekst = ""
    open_xml_from_file(number, relative_path) do | data |
      data.each_line { |f| tekst+= f } # unless f.nil? }
    end
    tekst
  end

  def Execute.initialize_bikestation_from_xml(doc, id)
    bike = BikeStation.new(id)
    bike.empty_locks = bike.ready_bikes = 0
    bike.online = false
    doc.elements.each('string/station/online') { |tag| bike.online =  "0".eql?(tag.text)}
    doc.elements.each('string/station/ready_bikes') {|tag| bike.ready_bikes = tag.text.to_i}
    doc.elements.each('string/station/empty_locks') {|tag| bike.empty_locks = tag.text.to_i}
    doc.elements.each('string/station/description') {|tag| bike.description = tag.text}
    doc.elements.each('string/station/longitute') {|tag| bike.longitude = tag.text}
    doc.elements.each('string/station/latitude') {|tag| bike.latitude = tag.text}

    bike
  end

  def Execute.initialize_bikestations_from_xml(doc)
    array = []
    doc.elements.each('string/station') { |tag|
      id = tag.text.to_i
      array << id unless id > 450
    }
    array
  end

end