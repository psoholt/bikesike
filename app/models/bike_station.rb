class BikeStation
  attr_reader :online, :ready_bikes, :empty_locks

  #@online = "hei"
  #@@static_variable = "statisk variabel"
  #$global_variable = "global variabel"

  def initialize(doc)
    doc.elements.each('string/station/online') {|tag| @online = tag.text}
    doc.elements.each('string/station/ready_bikes') {|tag| @ready_bikes = tag.text}
    doc.elements.each('string/station/empty_locks') {|tag| @empty_locks = tag.text}
    doc.elements.each('string/station/description') {|tag| @description = tag.text}
    doc.elements.each('string/station/longitute') {|tag| @longitude = tag.text}
    doc.elements.each('string/station/latitude') {|tag| @latitude = tag.text}
  end

  def to_s

    "Online: "+ "0".eql?(@online).to_s + ",  ReadyBikes: " + @ready_bikes + ", EmptyLocks: " + @empty_locks + \
 ", Posisjon: " + @longitude +", " + @latitude + "\n\t" + @description
  end
end