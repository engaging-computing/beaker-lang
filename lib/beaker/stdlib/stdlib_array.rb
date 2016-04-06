module Beaker
  def self.init_array
    # Takes an array and sets the default value.
    @stdlib.add 'default', FunctionType.new('default', lambda do |env, array, default|
      check_default_value('default', array, default)
      ArrayType.new(array.value, array.contains, array.curr_pos, default.get)
    end, [AnyArrayContract.new, AnyContract.new(true)])

    # Takes an array and an optional default value (in case the specified location
    #   in the array is nil or out of bounds), and returns an array object with
    #   the current position set to n + 1, where n is the current position of the
    #   array.
    @stdlib.add 'next', FunctionType.new('next', lambda do |env, array, default|
      if default.nil?
        ArrayType.new(array.value, array.contains, array.curr_pos + 1, array.default)
      else
        check_default_value('next', array, default)
        ArrayType.new(array.value, array.contains, array.curr_pos + 1, default.get)
      end
    end, [AnyArrayContract.new, AnyContract.new(true)])

    # Takes an array, an offset, and an optional default value (in case the specified
    #   location in the array is nil or out of bounds), and returns an array object
    #   with the current position set to n + the provided offset, where n is the
    #   current position of the array
    @stdlib.add 'next_p', FunctionType.new('next_p', lambda do |env, array, idx, default|
      if default.nil?
        ArrayType.new(array.value, array.contains, array.curr_pos + idx.get, array.default)
      else
        check_default_value('next_p', array, default)
        ArrayType.new(array.value, array.contains, array.curr_pos + idx.get, default.get)
      end
    end, [AnyArrayContract.new, Contract.new(:number), AnyContract.new(true)])

    # Takes an array and an optional default value (in case the specified location
    #   in the array is nil or out of bounds), and returns an array object with
    #   the current position set to n - 1, where n is the current position of the
    #   array.
    @stdlib.add 'prev', FunctionType.new('prev', lambda do |env, array, default|
      if default.nil?
        ArrayType.new(array.value, array.contains, array.curr_pos - 1, array.default)
      else
        check_default_value('prev', array, default)
        ArrayType.new(array.value, array.contains, array.curr_pos - 1, default.get)
      end
    end, [AnyArrayContract.new, AnyContract.new(true)])

    # Takes an array, an offset, and an optional default value (in case the specified
    #   location in the array is nil or out of bounds), and returns an array object
    #   with the current position set to n - the provided offset, where n is the
    #   current position of the array.
    @stdlib.add 'prev_p', FunctionType.new('prev_p', lambda do |env, array, idx, default|
      if default.nil?
        ArrayType.new(array.value, array.contains, array.curr_pos - idx.get, array.default)
      else
        check_default_value('prev_p', array, default)
        ArrayType.new(array.value, array.contains, array.curr_pos - idx.get, default.get)
      end
    end, [AnyArrayContract.new, Contract.new(:number), AnyContract.new(true)])

    # Takes an array and an optional default value (in case the specified location
    #   in the array is nil or out of bounds), and returns an array object with
    #   the current position set to 0.
    @stdlib.add 'first', FunctionType.new('first', lambda do |env, array, default|
      if default.nil?
        ArrayType.new(array.value, array.contains, 0, array.default)
      else
        check_default_value('first', array, default)
        ArrayType.new(array.value, array.contains, 0, default.get)
      end
    end, [AnyArrayContract.new, AnyContract.new(true)])

    # Takes an array, an offset, and an optional default value (in case the specified
    #   location in the array is nil or out of bounds), and returns an array object
    #   with the current position set to the provided offset.
    @stdlib.add 'first_p', FunctionType.new('first_p', lambda do |env, array, idx, default|
      if default.nil?
        ArrayType.new(array.value, array.contains, idx.get, array.default)
      else
        check_default_value('first_p', array, default)
        ArrayType.new(array.value, array.contains, idx.get, default.get)
      end
    end, [AnyArrayContract.new, Contract.new(:number), AnyContract.new(true)])

    # Takes an array and an optional default value (in case the specified location
    #   in the array is nil or out of bounds), and returns an array object with
    #   the current position set to the last spot in the array.
    @stdlib.add 'last', FunctionType.new('last', lambda do |env, array, default|
      if default.nil?
        ArrayType.new(array.value, array.contains, array.value.length - 1, array.default)
      else
        check_default_value('last', array, default)
        ArrayType.new(array.value, array.contains, array.value.length - 1, default.get)
      end
    end, [AnyArrayContract.new, AnyContract.new(true)])

    # Takes an array, an offset, and an optional default value (in case the specified
    #   location in the array is nil or out of bounds), and returns an array object
    #   with the current position set to the last spot in the array minues the
    #   provided offset.
    @stdlib.add 'last_p', FunctionType.new('last_p', lambda do |env, array, idx, default|
      if default.nil?
        ArrayType.new(array.value, array.contains, array.value.length - (1 + idx.get), array.default)
      else
        check_default_value('last_p', array, default)
        ArrayType.new(array.value, array.contains, array.value.length - (1 + idx.get), default.get)
      end
    end, [AnyArrayContract.new, Contract.new(:number), AnyContract.new(true)])

    @stdlib.add 'array_length', FunctionType.new('length', lambda do |env, array|
      NumberType.new(array.value.length)
    end, [AnyArrayContract.new])
  end

  private

  # Used for checking to see if the provided default value matches the type of the
  #   array that it is being used as a default for.  If the default type is an array,
  #   the contents of the default must match the contents of the array.  Otherwise,
  #   the type of the default must match the contents of the array.
  def self.check_default_value(func_name, array, default)
    if default.type == :array and default.contains != array.contains
      a = "[#{array.contains}]"
      b = array.contains
      c = "[#{default.contains}]"
      fail ArgumentTypeError.new(func_name, [a, b], [a, c])
    elsif default.type != array.contains
      a = "[#{array.contains}]"
      b = array.contains
      c = default.type
      fail ArgumentTypeError.new(func_name, [a, b], [a, c])
    end
  end
end

Beaker.init_array
