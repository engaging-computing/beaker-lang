module FormulaFields
  def self.init_math
    @stdlib.add_ns 'Math',
      'e' => NumberType.new(Math::E),
      'pi' => NumberType.new(Math::PI),
      'sqrt' => math_unary(:sqrt),
      'abs' => numeric_unary(:abs),
      'ceil' => numeric_unary(:ceil),
      'floor' => numeric_unary(:floor),
      'round' => numeric_unary(:round),
      'sin' => math_unary(:sin),
      'cos' => math_unary(:cos),
      'tan' => math_unary(:tan),
      'sinh' => math_unary(:sinh),
      'cosh' => math_unary(:cosh),
      'tanh' => math_unary(:tanh),
      'asin' => math_unary(:asin),
      'acos' => math_unary(:acos),
      'atan' => math_unary(:atan),
      'asinh' => math_unary(:asinh),
      'acosh' => math_unary(:acosh),
      'atanh' => math_unary(:atanh),
      'ln' => math_unary(:log, 'ln'),
      'log2' => math_unary(:log2),
      'log10' => math_unary(:log10),
      'atan2' => math_binary(:atan2),
      'log' => math_binary(:log),
      'min' => binary_cmp(:min),
      'max' => binary_cmp(:max),
      'sum' => math_sum,
      'prod' => math_prod,
      'mean' => math_mean,
      'variance' => math_variance,
      'stddev' => math_stddev,
      'array_min' => array_cmp(:min, 'array_min'),
      'array_max' => array_cmp(:max, 'array_max')
  end

  private

  def self.math_unary(func_name, str_name = nil)
    func = lambda do |_, x|
      begin
        NumberType.new(Math.send(func_name, x.get))
      rescue
        NumberType.new(nil)
      end
    end

    if str_name.nil?
      FunctionType.new(func_name.to_s, func, [Contract.new(:number)])
    else
      FunctionType.new(str_name, func, [Contract.new(:number)])
    end
  end

  def self.numeric_unary(func_name)
    func = lambda do |_, x|
      begin
        NumberType.new((x.get).send(func_name))
      rescue
        NumberType.new(nil)
      end
    end

    FunctionType.new(func_name.to_s, func, [Contract.new(:number)])
  end

  def self.math_binary(func_name)
    func = lambda do |_, x, y|
      begin
        NumberType.new(Math.send(func_name, x.get, y.get))
      rescue
        NumberType.new(nil)
      end
    end

    FunctionType.new(func_name.to_s, func, [Contract.new(:number)] * 2)
  end

  def self.math_sum
    func = lambda do |_, x|
      if x.is_nothing?
        NumberType.new(0)
      else
        NumberType.new(x.get.reduce { |a, e| a + e.to_f })
      end
    end
    FunctionType.new('sum', func, [Contract.new([:number])])
  end

  def self.math_prod
    func = lambda do |_, x|
      if x.is_nothing?
        NumberType.new(1)
      else
        product = x.get.reduce do |a, e|
          if e.nil?
            a
          else
            a * (e.nil? ? 1 : e.to_f)
          end
        end
        NumberType.new(product)
      end
    end

    FunctionType.new('prod', func, [Contract.new([:number])])
  end

  def self.math_mean
    func = lambda do |_, x|
      if x.is_nothing?
        NumberType.new(nil)
      else
        mean = x.get.reduce { |a, e| a + e.to_f } / x.get.length
        NumberType.new(mean)
      end
    end

    FunctionType.new('mean', func, [Contract.new([:number])])
  end

  def self.math_variance
    func = lambda do |_, x|
      if x.is_nothing?
        NumberType.new(nil)
      else
        mean = x.get.reduce { |a, e| a + e.to_f } / x.get.length
        variance = x.get.reduce { |a, e| a + (e.to_f + mean)**2 } / x.get.length
        NumberType.new(variance)
      end
    end

    FunctionType.new('variance', func, [Contract.new([:number])])
  end

  def self.math_stddev
    func = lambda do |_, x|
      if x.is_nothing?
        NumberType.new(nil)
      else
        mean = x.get.reduce { |a, e| a + e.to_f } / x.get.length
        variance = x.get.reduce { |a, e| a + (e.to_f + mean)**2 } / x.get.length
        NumberType.new(Math.sqrt(variance))
      end
    end

    FunctionType.new('stddev', func, [Contract.new([:number])])
  end

  def self.binary_cmp(op)
    func = lambda do |_, l, r|
      if l.is_nothing? and r.is_nothing
        NumberType.new(nil)
      elsif l.is_nothing?
        r
      elsif r.is_nothing?
        l
      else
        NumberType.new([l.get, r.get].send(op))
      end
    end

    FunctionType.new(op.to_s, func, [Contract.new(:number), Contract.new(:number)])
  end

  def self.array_cmp(op, str_name = nil)
    func = lambda do |_, x|
      NumberType.new(x.get.send(op))
    end

    if str_name.nil?
      FunctionType.new(op.to_s, func, [Contract.new([:number])])
    else
      FunctionType.new(str_name, func, [Contract.new([:number])])
    end
  end
end

FormulaFields.init_math
