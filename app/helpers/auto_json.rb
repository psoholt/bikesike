module AutoJson
  def instance_variable_as_hash
    h = {}
    instance_variables.each do |e|
      o = instance_variable_get e.to_sym
      h[e[1..-1]] = (o.respond_to? :instance_variable_as_hash) ? o.instance_variable_as_hash : o;
    end
    h
  end
end