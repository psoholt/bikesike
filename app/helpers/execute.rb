#http://scrumy.com/nuke54tumbril
#require 'bysykkel'
require 'open-uri'
require 'rexml/document'
include REXML
require_relative "../models/bike_station"
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

  def Execute.get_all_xml()
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

  def Execute.get_bike_station(id)
    Execute.initialize_bikestation_from_xml(Execute.get_stativ_xml(yield(id)) , id )
  end

  def Execute.get_all_stations()
    Execute.initialize_bikestations_from_xml( Execute.get_all_xml() )
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

    doc.elements.each('station') { |tag|
      puts tag.text.gsub("&lt;", "<").gsub("&gt;", ">")
    }

    "bike"
  end

  def Execute.racks
    Bysykkel::Rack.all
  end

end