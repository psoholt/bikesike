RAILS_ROOT = "#{File.dirname(__FILE__)}/.." unless defined?(RAILS_ROOT)

class CacheHelper
  @@cache_time_seconds = 30
  @bikehash

  def initialize hash_init = Hash.new
    @bikehash = hash_init
  end

  def put(an_object)
    if an_object.instance_variable_defined?(:@id)

      @bikehash[an_object.id] = an_object
      puts @bikehash
    end
  end

  def get(id)
    bike_station = @bikehash[id]
    return nil if bike_station.nil?
    return nil if bike_station.seconds_since_creation > @@cache_time_seconds
    bike_station
  end

  def get_all
    @bikehash
  end

end