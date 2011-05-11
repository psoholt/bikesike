require_relative "../helpers/execute.rb"
require_relative "../helpers/cache_helper.rb"

class BysykkelController < ActionController::Base
#  helper :all # include all helpers, all the time
#  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  def station
    @bike_station = Execute.get_bike_station(params[:id])
    
    respond_to do |format|
        format.xml  { render :xml => @bike_station }
        format.json { render :json => @bike_station }
    end
  end

  def testcache
    cache_helper = get_cache
#    cache_helper = Rails.cache.read("cache_helper")
    puts cache_helper.get_all.to_s
    cache_helper.put(BikeStation.new cache_helper.get_all.count)
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

  def all
    # med id, long, lat (+ bikes and locks and online)
    #@allstations = Execute.get_all_stations()
    @allstations = Execute.get_all_stations

    respond_to do |format|
        format.json { render :json => @allstations }
    end
  end

  private
  def get_cache_helper
    rails_cache = Rails.cache.read("cache_helper")
    rails_cache_hash = rails_cache.all.dup unless rails_cache.nil?
    if rails_cache_hash.nil?
      rails_cache_hash = Hash.new
    end
    CacheHelper.new rails_cache_hash
  end

  def put_cache_helper cache_helper
    Rails.cache.write("cache_helper", cache_helper) unless Rails.cache.nil?
  end

end
