require 'json'
require 'xml'
require 'auto_json.rb'
require 'auto_xml.rb'

class BikeStation
  include AutoJson
  include AutoXml
  attr_accessor :id, :online, :ready_bikes, :empty_locks, :longitude, :latitude, :description
  attr_reader :time_created

  def initialize(id)
    @time_created = Time.now
    @id = id;
  end

  def to_s
    "Bysykkelstativ nr: "+ id.to_s + "  Online: "+ online.to_s + ",  ReadyBikes: " +  (@ready_bikes.to_s||"null") + ", EmptyLocks: " + (@empty_locks.to_s||"nil") + \
  ", Posisjon: " + (@longitude||"null") +", " + (@latitude||"nil") + "\n\t" + (@description||"")
  end

  def to_json *a
    variables = instance_variable_as_hash
    variables.delete(:time_created.to_s)
    variables.to_json *a
  end

  def to_xml *a
    variables = instance_variable_as_hash
    variables.delete(:time_created.to_s)
    variables.to_xml *a
  end

  def seconds_since_creation
    Time.now.to_i- @time_created.to_i
  end
end
