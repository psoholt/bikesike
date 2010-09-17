#http://scrumy.com/nuke54tumbril
require 'open-uri'
require 'rexml/document'
include REXML

class Execute
  public
  def self.webOpenXML(number)
    open("http://www.adshel.no/js/getracknr.php?id="+number.to_s)
  end

  def Execute.get_stativ_textxml_web (number)
    tekst = ""
    webOpenXML(number) do | web |
      web.each_line { |f| tekst+= f } #unless f.nil? }
    end
    tekst
  end

  def Execute.get_stativ_xml
    tekst = ""
    data = yield
    data.each_line { |f| tekst+= f } #unless f.nil? }
    Document.new(tekst)
  end 

  def Execute.get_bike_station
    BikeStation.new(Execute.get_stativ_xml { yield } )
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

class BikeStation
  attr_reader :online, :ready_bikes, :empty_locks

  #@online = "hei"
  #@@static_variable = "statisk variabel"
  #$global_variable = "global variabel"

  def initialize(doc)
    doc.elements.each('string/station/online') {|tag| @online = tag.text}
    doc.elements.each('string/station/ready_bikes') {|tag| @ready_bikes = tag.text}
    doc.elements.each('string/station/empty_locks') {|tag| @empty_locks = tag.text}
    doc.elements.each('string/station/description') {|tag| @description = tag.text}
    doc.elements.each('string/station/longitute') {|tag| @longitude = tag.text}
    doc.elements.each('string/station/latitude') {|tag| @latitude = tag.text}
  end

  def to_s

    "Online: "+ "0".eql?(@online).to_s + ",  ReadyBikes: " + @ready_bikes + ", EmptyLocks: " + @empty_locks + \
 ", Posisjon: " + @longitude +", " + @latitude + "\n\t" + @description
  end
end


#bike = Execute.get_bike_station { Execute.file_open_xml(3) }
#puts bike


