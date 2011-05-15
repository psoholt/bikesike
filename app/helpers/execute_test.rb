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
    bike_station = Execute.get_bike_station(4)
    puts bike_station
    assert_not_equal nil, bike_station.empty_locks
  end

  def test_getbikestation_fromxmlfile_emptylocksIs15
    bike_station = Execute.get_bike_station_yield(3) {|id| Execute.open_xml_from_file(id, File.dirname($0)+"/") }
    puts bike_station
    assert_equal 15, bike_station.empty_locks
  end

  def test_getbikestation_fromxmlfileinwintertime_emptylocksIs0
    bike_station = Execute.get_bike_station_yield(2) {|id| Execute.open_xml_from_file(id, File.dirname($0)+"/") }
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
    bike = Execute.get_bike_station_yield(3) {|id| Execute.open_xml_from_file(id, File.dirname($0)+"/") }
    puts bike.to_json
  end

  def test_caching
    bike = Execute.get_bike_station_yield(3) {|id| Execute.open_xml_from_file(id, File.dirname($0)+"/") }
    bike2 = Execute.get_bike_station_yield(2) {|id| Execute.open_xml_from_file(id, File.dirname($0)+"/") }
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

  def test_caching_count
    bike = Execute.get_bike_station_yield(3) {|id| Execute.open_xml_from_file(id, File.dirname($0)+"/") }
    bike2 = Execute.get_bike_station_yield(2) {|id| Execute.open_xml_from_file(id, File.dirname($0)+"/") }
    cache_helper = CacheHelper.new
    #cache_helper.put bike
    puts cache_helper.get_all.count
  end

  def test_getbikestation_fromadshel_isnotempty
    bike_stations = Execute.get_all_station_numbers { Execute.web_open_all_xml() }
    puts bike_stations
  end

  def test_get_all_stations_isnil
    bike_stations = Execute.get_all_stations
    assert_equal(nil, bike_stations)
  end

  def test_get_all_stations_isnotempty
    bike_stations = Execute.get_all_stations CacheMock.new
    assert_equal(nil, bike_stations)
  end

  class CacheMock
    def get_all
      return { 1 => BikeStation.new(1), 2 => BikeStation.new(2)}
    end
  end

  def test_getbikestation_fromxmlfile_longitudetodec
    bike_station = Execute.get_bike_station_yield(3) {|id| Execute.open_xml_from_file(id, File.dirname($0)+"/") }
    puts bike_station
    puts bike_station.latitude.to_f.to_s
    puts (bike_station.latitude.to_f < 2.4).to_s

  end

end