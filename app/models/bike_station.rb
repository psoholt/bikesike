#require 'rubygems'
#require 'dm-core'
#require 'dm-migrations'
##DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite::memory:')
#DataMapper.setup(:default, 'sqlite::memory:')
##DataMapper::Logger.new($stdout)

class BikeStation << ActiveREcord::Base
#  include DataMapper::Resource
#  property :id, Integer, :key => true
#  property :online, Boolean
#  property :ready_bikes, Integer
#  property :empty_locks, Integer
#  property :description, Text
#  property :longitude, String
#  property :latitude, String
#  property :created_at, DateTime
  
  attr_accessor :online, :ready_bikes, :empty_locks

  #@online = "hei"
  #@@static_variable = "statisk variabel"
  #$global_variable = "global variabel"

  def initialize(&block)
    instance_eval &block
  end

  def initialize(doc, id)
    @id = id
    doc.elements.each('string/station/online') {|tag| @online =  "0".eql?(tag.text)}
    doc.elements.each('string/station/ready_bikes') {|tag| @ready_bikes = tag.text}
    doc.elements.each('string/station/empty_locks') {|tag| @empty_locks = tag.text}
    doc.elements.each('string/station/description') {|tag| @description = tag.text}
    doc.elements.each('string/station/longitute') {|tag| @longitude = tag.text}
    doc.elements.each('string/station/latitude') {|tag| @latitude = tag.text}
  end

  def to_s
    "Bysykkelstativ nr: "+ id.to_s + "  Online: "+ online.to_s + ",  ReadyBikes: " + @ready_bikes + ", EmptyLocks: " + @empty_locks + \
  ", Posisjon: " + @longitude +", " + @latitude + "\n\t" + @description
  end
end

#DataMapper.finalize
#DataMapper.auto_migrate!
