class BikeStation 

  
  attr_accessor :stativ_nr,:online, :ready_bikes, :empty_locks, :longitude, :latitude, :description
  attr_reader :time_created

  def initialize
    @time_created = Time.now
  end

  def to_s
    "Bysykkelstativ nr: "+ stativ_nr.to_s + "  Online: "+ online.to_s + ",  ReadyBikes: " +  (@ready_bikes.to_s||"null") + ", EmptyLocks: " + (@empty_locks.to_s||"nil") + \
  ", Posisjon: " + (@longitude||"null") +", " + (@latitude||"nil") + "\n\t" + (@description||"")
  end

  def seconds_since_creation
    Time.now.to_i- @time_created.to_i
  end

end
