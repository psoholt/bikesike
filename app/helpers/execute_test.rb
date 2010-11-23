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


end