require_relative "execute.rb"
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
    bikestation = BikeStation.new
    bikestation.description = "Lalala"
    bikestation.stativ_nr = 1
    sleep 3
    seconds = bikestation.seconds_since_creation
    puts seconds
    result = seconds>=2
    assert_equal true, result
#    assert_compare(2,">=",seconds)
  end

  def test_fetchjson_open_xml_from_file
    bike = Execute.get_bike_station(3) {|id| Execute.open_xml_from_file(id, File.dirname($0)+"/") }
    puts bike.as_json
    puts bike.to_json
    #fetchXmlController =  FetchXmlController.new
    #puts fetchXmlController.fetchjson_fromfile(3)
  end

end