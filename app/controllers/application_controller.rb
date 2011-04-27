# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require_relative "../helpers/execute.rb"

class ApplicationController < ActionController::Base
#  helper :all # include all helpers, all the time
#  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  def getjson
#    puts params
    @bike_station = Execute.get_bike_station(params[:id]) {|id| Execute.web_open_xml(params[:id]) }

    #puts @bike_station

    respond_to do |format|
        format.xml  { render :xml => @bike_station }
        format.json { render :json => @bike_station }
    end
  end

  def getmany
#    puts params
    @bs1 = BikeStation.new(1)
    @bs1.longitude = "10.709009170532226"
    @bs1.latitude = "59.92786125852981"

    @bs2 = BikeStation.new(2)
    @bs2.longitude = "10.708515644073486"
    @bs2.latitude = "59.92805479800621"

    @bs3 = BikeStation.new(3)
    @bs3.longitude = "10.74413537979126"
    @bs3.latitude = "59.91124491211972"

    @bs4 = BikeStation.new(4)
    @bs4.longitude = "10.73866"
    @bs4.latitude = "59.92268"

#    puts @bs1
    
    @bike = [@bs1, @bs2, @bs3, @bs4]
    #, BikeStation.new(2), BikeStation.new(3), BikeStation.new(4) ]
#    @bike_station = Execute.get_bike_station(params[:id]) {|id| Execute.web_open_xml(params[:id]) }

    #puts @bike_station

    respond_to do |format|
        format.json { render :json => @bike }
    end
  end
end
