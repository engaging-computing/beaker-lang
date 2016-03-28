module Beaker
  def self.init_math
    # "e" and "pi" are seperate because they're variables.  It's tenuous reasoning,
    #   but I really dislike how expressions looked when e and pi were in the math
    #   module.
    @stdlib.add 'e', NumberType.new(Math::E)
    @stdlib.add 'pi', NumberType.new(Math::PI)

    # Definition of the math module.  Everything is created according to a function
    #   that produces a wrapper around a ruby function.
    @stdlib.add 'sqrt', math_unary(:sqrt)
    @stdlib.add 'abs', numeric_unary(:abs)
    @stdlib.add 'ceil', numeric_unary(:ceil)
    @stdlib.add 'floor', numeric_unary(:floor)
    @stdlib.add 'round', numeric_unary(:round)
    @stdlib.add 'sin', math_unary(:sin)
    @stdlib.add 'cos', math_unary(:cos)
    @stdlib.add 'tan', math_unary(:tan)
    @stdlib.add 'sinh', math_unary(:sinh)
    @stdlib.add 'cosh', math_unary(:cosh)
    @stdlib.add 'tanh', math_unary(:tanh)
    @stdlib.add 'asin', math_unary(:asin)
    @stdlib.add 'acos', math_unary(:acos)
    @stdlib.add 'atan', math_unary(:atan)
    @stdlib.add 'asinh', math_unary(:asinh)
    @stdlib.add 'acosh', math_unary(:acosh)
    @stdlib.add 'atanh', math_unary(:atanh)
    @stdlib.add 'ln', math_unary(:log, 'ln')
    @stdlib.add 'log2', math_unary(:log2)
    @stdlib.add 'log10', math_unary(:log10)
    @stdlib.add 'atan2', math_binary(:atan2)
    @stdlib.add 'log', math_binary(:log)
    @stdlib.add 'min', binary_cmp(:min)
    @stdlib.add 'max', binary_cmp(:max)
    @stdlib.add 'sum', math_sum
    @stdlib.add 'prod', math_prod
    @stdlib.add 'mean', math_mean
    @stdlib.add 'variance', math_variance
    @stdlib.add 'stddev', math_stddev
    @stdlib.add 'array_min', array_cmp(:min, 'array_min')
    @stdlib.add 'array_max', array_cmp(:max, 'array_max')
  end

  private

  # Creates functions that take one number, and return the result of applying it
  #   to an internal ruby function.  "func_name" sepcifies what function to use,
  #   and "str_name" specifies what the language itself calls the function (if
  #   it is different).  The function that is applied must belong to the Math
  #   module in Ruby.
  def self.math_unary(func_name, str_name = nil)
    name = str_name.nil? ? func_name.to_s : str_name
    FunctionType.new(name, lambda do |_, x|
      begin
        NumberType.new(Math.send(func_name, x.get))
      rescue
        NumberType.new(nil)
      end
    end, [Contract.new(:number)])
  end

  # Creates functions that take two numbers, and return the result of applying them
  #   to an internal ruby function.  "func_name" sepcifies what function to use,
  #   and "str_name" specifies what the language itself calls the function (if
  #   it is different).  The function that is applied must belong to the Math
  #   module in Ruby.
  def self.math_binary(func_name, str_name = nil)
    name = str_name.nil? ? func_name.to_s : str_name
    FunctionType.new(name, lambda do |_, x, y|
      begin
        NumberType.new(Math.send(func_name, x.get, y.get))
      rescue
        NumberType.new(nil)
      end
    end, [Contract.new(:number), Contract.new(:number)])
  end

  # Creates functions that take one number, and return the result of applying it
  #   to an internal ruby function.  "func_name" sepcifies what function to use,
  #   and "str_name" specifies what the language itself calls the function (if
  #   it is different).  The function that is applied must be a method of the
  #   Float object.
  def self.numeric_unary(func_name, str_name = nil)
    name = str_name.nil? ? func_name.to_s : str_name
    FunctionType.new(name, lambda do |_, x|
      begin
        NumberType.new((x.get).send(func_name))
      rescue
        NumberType.new(nil)
      end
    end, [Contract.new(:number)])
  end

  # Creates functions that compare two numbers using an internal Ruby function.
  #   "func_name" sepcifies what function to use, and "str_name" specifies what
  #   the language itself calls the function (if it is different).  The function
  #   must be a method of the Array object.
  def self.binary_cmp(func_name, str_name = nil)
    name = str_name.nil? ? func_name.to_s : str_name
    FunctionType.new(name, lambda do |_, l, r|
      if l.is_nothing? and r.is_nothing?
        NumberType.new(nil)
      elsif l.is_nothing?
        r
      elsif r.is_nothing?
        l
      else
        NumberType.new([l.get, r.get].send(func_name))
      end
    end, [Contract.new(:number), Contract.new(:number)])
  end

  # Creates functions that compare arrays of numbers using an internal Ruby function.
  #   "func_name" sepcifies what function to use, and "str_name" specifies what
  #   the language itself calls the function (if it is different).  The function
  #   must be a method of the Array object.
  def self.array_cmp(func_name, str_name = nil)
    name = str_name.nil? ? func_name.to_s : str_name
    FunctionType.new(name, lambda do |_, x|
      vals = x.value.select { |x| !x.nil? }
      if vals.empty?
        NumberType.new(nil)
      else
        NumberType.new(vals.send(func_name))
      end
    end, [Contract.new([:number])])
  end

  # Defines the function that takes an array of numbers and sums over the array.
  #   An empty array has a sum of 0.
  def self.math_sum
    FunctionType.new('sum', lambda do |_, x|
      if x.is_nothing?
        NumberType.new(0)
      else
        sum = x.value.reduce(0) { |a, e| e.nil? ? a : a + e.to_f }
        NumberType.new(sum)
      end
    end, [Contract.new([:number])])
  end

  # Defines a function that takes an array of numbers and multiplies over the array.
  #   An empty array has a product of 1.
  def self.math_prod
    FunctionType.new('prod', lambda do |_, x|
      if x.is_nothing?
        NumberType.new(1)
      else
        product = x.value.reduce(1) { |a, e| e.nil? ? a : a * e.to_f }
        NumberType.new(product)
      end
    end, [Contract.new([:number])])
  end

  # Defines a function that takes the average of an array of numbers.  An empty
  #   array has a mean of 0.
  def self.math_mean
    FunctionType.new('mean', lambda do |_, x|
      if x.is_nothing?
        NumberType.new(0)
      else
        sum = x.value.reduce(0) { |a, e| e.nil? ? a : a + e.to_f }
        NumberType.new(sum / x.value.length)
      end
    end, [Contract.new([:number])])
  end

  def self.math_variance
    FunctionType.new('variance', lambda do |_, x|
      if x.is_nothing?
        NumberType.new(0)
      else
        sum = x.value.reduce(0) { |a, e| e.nil? ? a : a + e.to_f }
        mean = sum / x.value.length
        var_inner = x.value.reduce(0) { |a, e| e.nil? ? a : a + (e.to_f - mean)**2 }
        NumberType.new(var_inner / x.value.length)
      end
    end, [Contract.new([:number])])
  end

  def self.math_stddev
    FunctionType.new('stddev', lambda do |_, x|
      if x.is_nothing?
        NumberType.new(0)
      else
        sum = x.value.reduce(0) { |a, e| e.nil? ? a : a + e.to_f }
        mean = sum / x.value.length
        var_inner = x.value.reduce(0) { |a, e| e.nil? ? a : a + (e.to_f - mean)**2 }
        NumberType.new(Math.sqrt(var_inner / x.value.length))
      end
    end, [Contract.new([:number])])
  end
end

Beaker.init_math
