require 'json'
require_relative '../helpers/auto_json.rb'

class BikeLight
  include AutoJson
  attr_accessor :id, :longitude, :latitude

  def initialize(id)
    @id = id;
  end

  def initialize(id, longitude, latitude)
    @id = id;
    @longitude = longitude;
    @latitude = latitude;
  end

  def to_json *a
    variables = instance_variable_as_hash
    variables.to_json *a
  end
end
