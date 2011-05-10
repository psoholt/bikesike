require_relative "../helpers/execute.rb"

class BysykkelController < ActionController::Base
#  helper :all # include all helpers, all the time
#  protect_from_forgery # See ActionController::RequestForgeryProtection for details


  def getjson
    @bike_station = Execute.get_bike_station(params[:id]) {|id| Execute.web_open_xml(params[:id]) }

    respond_to do |format|
        format.xml  { render :xml => @bike_station }
        format.json { render :json => @bike_station }
    end
  end

# def getallfromlocation (topLeft, bottomRight)
# return json with locks and bikes for all stations

#  def incrementnumber
#
#    @testvalue = @testvalue+1
#
#    respond_to do |format|
#      format.json { render :xml => @testvalue }
#    end
#  end

  def getmany
    # med id, long, lat (+ bikes and locks and online)
    #@allstations = Execute.get_all_stations()

    @racks = []
    #(1..108).each do |i|
    (1..10).each do |i|
      @racks << BikeStation.new(i)
    end
    
    respond_to do |format|
        format.json { render :json => @racks }
    end
  end
end
