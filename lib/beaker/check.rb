module Beaker
  def generate_dummy_env(parent, read_only, ns, reqs)
    env = Environment.new(read_only, parent)

    allowed_types = [:number, :text, :latitude, :longitude, :timestamp]
    hash = {}
    reqs.keys.each do |name|
      type = reqs[name]
      val = if allowed_types.include? type
              Beaker.get_nothing_type(type)
            elsif type.is_a? Array and type.length == 1
              ArrayType.new([], type[0])
            else
              TextType.new('a')
            end
      if ns.nil?
        env.add name.to_s, val
      else
        hash[name.to_s] = val
      end
    end

    unless ns.nil?
      env.add ns, hash
    end

    env
  end

  def check(expr, env, end_type)
    ret = expr.map { |y| y.evaluate(env) }[-1]
    if ret.type != end_type and ret.type != :nothing
      puts expr
      'oops'
    end
  rescue => e
    e.to_s
  end
end
