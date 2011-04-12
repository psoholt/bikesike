class CacheHelper
  @@cache_time_seconds = 30
  @bikehash = Hash.new

  def put(an_object)
    if an_object.instance_variable_defined?(:@id)
      @bikehash = Hash.new if @bikehash.nil?

      @bikehash[an_object.id] = an_object
      puts @bikehash
    end
  end

  def get(id)
    bikeStation = @bikehash[id]
    return nil if bikeStation.nil?
    return nil if bikeStation.seconds_since_creation > @@cache_time_seconds
    bikeStation
  end

end