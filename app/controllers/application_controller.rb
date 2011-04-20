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
    @bike = [BikeStation.new(1), BikeStation.new(2), BikeStation.new(3), BikeStation.new(4) ]
#    @bike_station = Execute.get_bike_station(params[:id]) {|id| Execute.web_open_xml(params[:id]) }

    #puts @bike_station

    respond_to do |format|
        format.xml  { render :xml => @bike }
        format.json { render :json => @bike }
    end
  end
end
