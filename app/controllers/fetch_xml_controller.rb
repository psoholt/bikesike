require 'open-uri'

class FetchXmlController < ApplicationController

  @bikehash = Hash.new

  def fetchxml(id)
    return if id.is_a? int
    bike = Execute.get_bike_station(id) { |id| Execute.web_open_xml(id) }
    bike.to_json
  end

end


