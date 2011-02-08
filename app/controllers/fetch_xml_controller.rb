require 'open-uri'

class FetchXmlController < ApplicationController

  def fetchjson(id)
    return if !id.is_a? int
    bike = Execute.get_bike_station(id) { |id| Execute.web_open_xml(id) }
    bike.to_json
  end

  def fetchjson_fromfile(id)
    return if !id.is_a? int
    bike = Execute.get_bike_station(id) { |id| Execute.open_xml_from_file(id) }
    bike.to_json
  end

end


