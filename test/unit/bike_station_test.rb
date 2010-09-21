require 'test/unit'
require_relative '../../app/helpers/execute.rb'
#require '../../app/models/bike_station'

class BikeStationTest < Test::Unit::TestCase
  # Replace this with your real tests.
  setup do
    DataMapper::Logger.new($stdout, :debug)
    DataMapper.setup(:default, 'sqlite::memory:')
  end

  test "the truth" do

    bike_station = Execute.get_bike_station(3) {|id| Execute.file_open_xml(id, File.dirname($0)+"/../../app/Helpers/") }
    #bikehei = BikeStation.create(:stativ_nr => 3, :online=>true)
    puts "YOYOYOYO"+ bike_station.to_s
    biktest = BikeStation.get(3)
    puts "HALLLOOO" + biktest.to_s
    assert_equal 15, biktest.empty_locks
  end
end
