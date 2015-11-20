module FormulaFields
  def self.init_array
    @stdlib.add_class :array,
      # Takes an array and returns a string describing the contents of the array.
      'type' => MethodType.new('type', lambda do |env, this|
        TextType.new(this.contains.to_s.capitalize)
      end, [MethodContract.new]),

      # Takes an array and returns the length of the array.
      'length' => MethodType.new('length', lambda do |env, this|
        NumberType.new(this.value.length)
      end, [MethodContract.new]),

      # Takes an array and an optional default value (in case the specified location
      #   in the array is nil or out of bounds), and returns the value stored at
      #   position n, where n is the current position of the array.
      'get' => MethodType.new('get', lambda do |env, this, default|
        if default.nil?
          val = this.get
          pack_by_type(val, this.contains)
        else
          check_default_value('get', this, default)
          val = ArrayType.new(this.value, this.contains, this.curr_pos, default.get).get
          pack_by_type(val, this.contains)
        end
      end, [MethodContract.new, AnyContract.new(true)]),

      # Takes an array and returns a reversed version of it.  Does not modify the
      #   original array.
      'reverse' => MethodType.new('reverse', lambda do |env, this|
        ArrayType.new(this.value.reverse, this.contains, this.curr_pos, this.default)
      end, [MethodContract.new]),

      # Takes an array and converts it into a textual representation, surrounded
      #   by square brackets and delimited by commas.
      'to_text' => MethodType.new('to_text', lambda do |env, this|
        TextType.new(this.to_s)
      end, [MethodContract.new])

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
        check_default_value('nextidx', array, default)
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

FormulaFields.init_array
