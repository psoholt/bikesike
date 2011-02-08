class CacheHelper
  @bikehash = Hash.new

  def put(an_object)
    if an_object.instance_variable_defined?(:@id)
      @bikehash = Hash.new if @bikehash.nil?

      @bikehash[an_object.id] = an_object
      puts @bikehash
    end
  end

end