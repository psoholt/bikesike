require 'rubygems'
require 'dm-core'
require 'dm-migrations'
##DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3://test.db')
#DataMapper.setup(:default, 'sqlite::memory:')
DataMapper::Logger.new($stdout, :debug)
#DataMapper.setup(:default, 'sqlite3://test/test.db')
DataMapper.setup(:default, 'sqlite::memory:')


class BikeStation  #<< ActiveREcord::Base
  include DataMapper::Resource
#  property :id, Integer, :key => true
  property :stativ_nr, Integer, :key => true
#  property :id, Serial

  property :online, Boolean
  property :ready_bikes, Integer
  property :empty_locks, Integer
  property :description, Text
  property :longitude, String
  property :latitude, String
  property :created_at, DateTime
  
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

  def BikeStation.initialize_from_xml(doc, id)
#    bike = BikeStation.first_or_create(:stativ_nr=> id ).update(:stativ_nr =>)
    bike2 = BikeStation.first_or_create(:stativ_nr => id )
#    puts "inne i metode" + bike2.to_s

    bike = BikeStation.new
    bike.stativ_nr = id
    doc.elements.each('string/station/online') {|tag| bike.online =  "0".eql?(tag.text)}
    doc.elements.each('string/station/ready_bikes') {|tag| bike.ready_bikes = tag.text.to_i}
    doc.elements.each('string/station/empty_locks') {|tag| bike.empty_locks = tag.text.to_i}
    doc.elements.each('string/station/description') {|tag| bike.description = tag.text}
    doc.elements.each('string/station/longitute') {|tag| bike.longitude = tag.text}
    doc.elements.each('string/station/latitude') {|tag| bike.latitude = tag.text}
#    puts bike

    updated = bike2.update(stativ_nr => id,
      :online => bike.online,
      :ready_bikes => bike.ready_bikes,
      :empty_locks => bike.empty_locks,
      :description => bike.description,
      :longitude => bike.longitude,
      :latitude => bike.latitude)

    puts updated.to_s
    puts "saved bike"+bike2.to_s
    bike2 = find(:stativ_nr => id).each do |hei|
      puts hei.to_s
    end
    puts "loaded bike" + bike2.to_s
#    bike = get(id)
#    puts bike
#    bike.stativ_nr = id
#    doc.elements.each('string/station/online') {|tag| bike.online =  "0".eql?(tag.text)}
#    doc.elements.each('string/station/ready_bikes') {|tag| bike.ready_bikes = tag.text.to_i}
#    doc.elements.each('string/station/empty_locks') {|tag| bike.empty_locks = tag.text.to_i}
#    doc.elements.each('string/station/description') {|tag| bike.description = tag.text}
#    doc.elements.each('string/station/longitute') {|tag| bike.longitude = tag.text}
#    doc.elements.each('string/station/latitude') {|tag| bike.latitude = tag.text}
    bike2
  end

  def to_s
    "Bysykkelstativ nr: "+ stativ_nr.to_s + "  Online: "+ online.to_s + ",  ReadyBikes: " +  (@ready_bikes.to_s||"null") + ", EmptyLocks: " + (@empty_locks.to_s||"nil") + \
  ", Posisjon: " + (@longitude||"null") +", " + (@latitude||"nil") + "\n\t" + (@description||"")
  end
end

#DataMapper.finalize
BikeStation.auto_migrate!
#DataMapper.auto_migrate!
