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
    bikesite3 = Execute.file_open_xml(3, "./")
    assert_not_nil(bikesite3)
  end

  def test_the_truth
    bike_station = Execute.get_bike_station(3) {|id| Execute.file_open_xml(id, File.dirname($0)+"/") }
    assert_equal 15, bike_station.empty_locks
  end

  def test_get_seconds_from_creation_of_bikestation
    bikestation = BikeStation.new
    bikestation.description = "Lalala"
    bikestation.stativ_nr = 1
    sleep 3
    seconds = bikestation.seconds_since_creation
    puts seconds
    assert_true(seconds>=2)
  end

end