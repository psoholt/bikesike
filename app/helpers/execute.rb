#http://scrumy.com/nuke54tumbril
require 'open-uri'
require 'rexml/document'
include REXML
require "../models/bike_station"
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
    BikeStation.initialize_from_xml(Execute.get_stativ_xml { yield(id) }, id )
  end


  def Execute.file_open_xml (number)
    File.read("bikexmlexample"+number.to_s+".xml")
  end

  def Execute.get_stativ_textxml_from_file (number)
    tekst = ""
    file_open_xml(number) do | data |
      data.each_line { |f| tekst+= f } # unless f.nil? }
    end
    tekst
  end

end


DataMapper::Logger.new($stdout, :debug)
bike = Execute.get_bike_station(3) {|id| Execute.file_open_xml(id) }
#bikehei = BikeStation.create(:stativ_nr => 3, :online=>true)
puts "YOYOYOYO"+ bike.to_s
biktest =BikeStation.first(:stativ_nr =>3)
puts "HALLLOOO" + biktest.to_s

#bikehei = BikeStation.create(:stativ_nr => 2, :online=>true)
#bikehei = BikeStation.create(:stativ_nr => 1, :online=>true)
#
#puts bikehei
#puts bikehei.update(:ready_bikes=>4)
#puts bike
##puts bike.save.to_s
#
#
#bike2 = BikeStation.get(3)
#puts "hei"
#puts bike2
#
