require_relative "../helpers/execute.rb"
require_relative "../helpers/cache_helper.rb"

class BysykkelController < ActionController::Base
#  helper :all # include all helpers, all the time
#  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  def station
    cache_helper = get_cache_helper
    @bike_station = Execute.get_bike_station(params[:id], cache_helper)
    
    respond_to do |format|
        format.xml  { render :xml => @bike_station }
        format.json { render :json => @bike_station }
    end
    put_cache_helper cache_helper
  end

  def testcache
    cache_helper = get_cache
#    cache_helper = Rails.cache.read("cache_helper")
    puts cache_helper.get_all.to_s
    cache_helper.put(BikeStation.new cache_helper.get_all.count)
  end

  def allwithinarea
    cache_helper = get_cache_helper
    sw_lng = params[:swlng]
    sw_lat = params[:swlat]
    ne_lng = params[:nelng]
    ne_lat = params[:nelat]
    puts "sw_lng" + sw_lng.to_s
    puts "sw_lat" + sw_lat.to_s
    puts "ne_lng" + ne_lng.to_s
    puts "ne_lat" + ne_lat.to_s
    
    bikes_within_area = Execute.get_all_within_area(sw_lng, sw_lat, ne_lng, ne_lat, cache_helper)

    respond_to do |format|
        format.json { render :json => bikes_within_area }
    end
    put_cache_helper cache_helper
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

  def reset_cache
    Rails.cache.write("cache_helper", Hash.new)
  end

  def all
    # med id, long, lat (+ bikes and locks and online)
    cache_helper = get_cache_helper
    @allstations = Execute.get_all_stations cache_helper

    respond_to do |format|
        format.json { render :json => @allstations }
    end
    #puts @allstations
    put_cache_helper cache_helper
  end

  private
  def get_cache_helper
    rails_cache_hash_frozen = Rails.cache.read("cache_helper")
    rails_cache_hash = nil
    unless(rails_cache_hash_frozen.nil?)
      rails_cache_hash = rails_cache_hash_frozen.dup
    end
    if rails_cache_hash.nil?
      rails_cache_hash = Hash.new
    end
    #puts rails_cache_hash.to_s
    CacheHelper.new rails_cache_hash
  end

  def put_cache_helper cache_helper
    Rails.cache.write("cache_helper", cache_helper.get_all) unless Rails.cache.nil? || cache_helper.nil?
  end

end
