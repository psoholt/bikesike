class CreateBikeStations < ActiveRecord::Migration
  def self.up
    create_table :bike_stations do |t|
      t.column :id
#  include DataMapper::Resource
#  property :id, Integer, :key => true
#  property :online, Boolean
#  property :ready_bikes, Integer
#  property :empty_locks, Integer
#  property :description, Text
#  property :longitude, String
#  property :latitude, String
#  property :created_at, DateTime
      t.timestamps
    end
  end

  def self.down
    drop_table :bike_stations
  end
end
