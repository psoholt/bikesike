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
    BikeStation.initialize_from_xml(Execute.get_stativ_xml { yield(id) }, id )
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
end