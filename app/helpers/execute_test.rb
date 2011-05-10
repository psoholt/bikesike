require_relative "execute.rb"
require_relative "cache_helper.rb"
require "test/unit"

class ExecuteTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_read_xml_file
    bikesite3 = Execute.open_xml_from_file(3, "./")
    assert_not_nil(bikesite3)
  end

  def test_getbikestation_fromadshel_isnotempty
    bike_station = Execute.get_bike_station(4) {|id| Execute.web_open_xml(id) }
    puts bike_station
    assert_not_equal nil, bike_station.empty_locks
  end

  def test_getbikestation_fromxmlfile_emptylocksIs15
    bike_station = Execute.get_bike_station(3) {|id| Execute.open_xml_from_file(id, File.dirname($0)+"/") }
    puts bike_station
    assert_equal 15, bike_station.empty_locks
  end

  def test_getbikestation_fromxmlfileinwintertime_emptylocksIs0
    bike_station = Execute.get_bike_station(2) {|id| Execute.open_xml_from_file(id, File.dirname($0)+"/") }
    puts bike_station
    assert_equal 0, bike_station.empty_locks
  end

  def test_get_seconds_from_creation_of_bikestation
    bikestation = BikeStation.new(1)
    bikestation.description = "Lalala"
    sleep 3
    seconds = bikestation.seconds_since_creation
    puts seconds
    result = seconds>=2
    assert_equal true, result
  end

  def test_fetchjson_open_xml_from_file_ShouldNotThrowException
    bike = Execute.get_bike_station(3) {|id| Execute.open_xml_from_file(id, File.dirname($0)+"/") }
    puts bike.to_json
  end

  def test_caching
    bike = Execute.get_bike_station(3) {|id| Execute.open_xml_from_file(id, File.dirname($0)+"/") }
    bike2 = Execute.get_bike_station(2) {|id| Execute.open_xml_from_file(id, File.dirname($0)+"/") }
    cache_helper = CacheHelper.new
    cache_helper.put bike
    cache_helper.put bike
    cache_helper.put bike2
    bike_from_hash = cache_helper.get 2
    assert_equal bike_from_hash, bike2
    puts bike_from_hash
    assert_equal bike_from_hash.id, 2
    bike_from_hash_second = cache_helper.get 3
    puts bike_from_hash_second
  end

  def test_racks
    
  end
  
end