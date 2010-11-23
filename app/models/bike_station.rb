require 'rubygems'
require 'dm-core'
require 'dm-migrations'
##DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3://test.db')
#DataMapper.setup(:default, 'sqlite::memory:')
DataMapper::Logger.new($stdout, :debug)
#DataMapper.setup(:default, 'sqlite3://test/test.db')
DataMapper.setup(:default, 'sqlite::memory:')


class BikeStation  #<< ActiveREcord::Base
#  include DataMapper::Resource#  property :id, Integer, :key => true
#  property :stativ_nr, Integer, :key => true

#  property :online, Boolean
#  property :ready_bikes, Integer
#  property :empty_locks, Integer
#  property :description, Text
#  property :longitude, String
#  property :latitude, String
#  property :created_at, DateTime
  
  attr_accessor :stativ_nr,:online, :ready_bikes, :empty_locks, :longitude, :latitude, :description

  #@online = "hei"
  #@@static_variable = "statisk variabel"
  #$global_variable = "global variabel"

#  def initialize(doc, id)
#    @id = id
#    doc.elements.each('string/station/online') {|tag| @online =  "0".eql?(tag.text)}
#    doc.elements.each('string/station/ready_bikes') {|tag| @ready_bikes = tag.text}
#    doc.elements.each('string/station/empty_locks') {|tag| @empty_locks = tag.text}
#    doc.elements.each('string/station/description') {|tag| @description = tag.text}
#    doc.elements.each('string/station/longitute') {|tag| @longitude = tag.text}
#    doc.elements.each('string/station/latitude') {|tag| @latitude = tag.text}
#  end



  def to_s
    "Bysykkelstativ nr: "+ stativ_nr.to_s + "  Online: "+ online.to_s + ",  ReadyBikes: " +  (@ready_bikes.to_s||"null") + ", EmptyLocks: " + (@empty_locks.to_s||"nil") + \
  ", Posisjon: " + (@longitude||"null") +", " + (@latitude||"nil") + "\n\t" + (@description||"")
  end
end

#DataMapper.finalize
#BikeStation.auto_migrate!
#DataMapper.auto_migrate!
