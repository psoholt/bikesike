#http://scrumy.com/nuke54tumbril
require 'open-uri'
require 'rexml/document'
include REXML
require_relative "../models/bike_station"
class Execute
  public
  def Execute.web_open_xml(number)
    open("http://www.adshel.no/js/getracknr.php?id="+number.to_s)
  end

  def Execute.get_stativ_textxml_web (number)
    tekst = ""
    web_open_xml(number) do | web |
      web.each_line { |f| tekst+= f }
    end
    tekst
  end

  def Execute.get_stativ_xml
    tekst = ""
    data = yield
    data.each_line { |f| tekst+= f }
    Document.new(tekst)
  end 

  def Execute.get_bike_station(id)
    #BikeStation.new(Execute.get_stativ_xml { yield(id) }, id )
    Execute.initialize_bikestation_from_xml(Execute.get_stativ_xml { yield(id) }, id )
  end


  def Execute.file_open_xml (number, relative_path )
    File.read(relative_path+"bikexmlexample"+number.to_s+".xml")
  end

  def Execute.get_stativ_textxml_from_file (number, relative_path)
    tekst = ""
    file_open_xml(number, relative_path) do | data |
      data.each_line { |f| tekst+= f } # unless f.nil? }
    end
    tekst
  end

    def Execute.initialize_bikestation_from_xml(doc, id)
#    bike2 = BikeStation.first_or_create(:stativ_nr => id )

    bike = BikeStation.new
    bike.stativ_nr = id
    doc.elements.each('string/station/online') {|tag| bike.online =  "0".eql?(tag.text)}
    doc.elements.each('string/station/ready_bikes') {|tag| bike.ready_bikes = tag.text.to_i}
    doc.elements.each('string/station/empty_locks') {|tag| bike.empty_locks = tag.text.to_i}
    doc.elements.each('string/station/description') {|tag| bike.description = tag.text}
    doc.elements.each('string/station/longitute') {|tag| bike.longitude = tag.text}
    doc.elements.each('string/station/latitude') {|tag| bike.latitude = tag.text}
#    puts bike

#    updated = bike2.update(:stativ_nr => id,
#      :online => bike.online,
#      :ready_bikes => bike.ready_bikes,
#      :empty_locks => bike.empty_locks,
#      :description => bike.description,
#      :longitude => bike.longitude,
#      :latitude => bike.latitude)
#
#    puts updated.to_s
#    puts "saved bike"+bike2.to_s
#    bike2 = find(:stativ_nr => id).each do |hei|
#      puts hei.to_s
#    end
#    puts "loaded bike" + bike2.to_s

    bike
  end

end