module FormulaFields
  def retrieve(array, pos, default)
    if pos >= 0 and pos < array.value.length
      if array.value[pos].nil?
        default
      else
        pack_by_type(array.value[pos], array.contains)
      end
    else
      default
    end
  end

  def check_default_value(array, default)
    if default.type == :array and default.contains != array.contains
      ac = array.contains
      dc = default.contains
      fail ArgumentTypeError.new('next', ["[#{ac}]", array.contains], ["[#{ac}]", "[#{dc}]"])
    elsif default.type != array.contains
      fail ArgumentTypeError.new('next', ["[#{array.contains}]", array.contains], ["[#{array.contains}]", default.type])
    end
  end

  def self.init_array
    @stdlib.add_class :array,
      'type' => MethodType.new('type', lambda do |env, this|
        TextType.new(this.contains.to_s.capitalize)
      end, [MethodContract.new]),

      'length' => MethodType.new('length', lambda do |env, this|
        NumberType.new(this.value.length)
      end, [MethodContract.new]),

      'curr' => MethodType.new('curr', lambda do |env, this, index, default|
        index = NumberType.new(0) if index.nil? or index.is_nothing?
        default = get_nothing_type(this.contains) if default.nil?
        pos = env.lookup('*').get + index.get
        retrieve(this, pos, default)
      end, [MethodContract.new, Contract.new(:number, true), MethodContract.new(true, true)]),

      'prev' => MethodType.new('prev', lambda do |env, this, index, default|
        index = NumberType.new(0) if index.nil? or index.is_nothing?
        default = get_nothing_type(this.contains) if default.nil?
        pos = env.lookup('*').get - 1 - index.get
        retrieve(this, pos, default)
      end, [MethodContract.new, Contract.new(:number, true), MethodContract.new(true, true)]),

      'next' => MethodType.new('next', lambda do |env, this, index, default|
        index = NumberType.new(0) if index.nil? or index.is_nothing?
        default = get_nothing_type(this.contains) if default.nil?
        pos = env.lookup('*').get + 1 + index.get
        retrieve(this, pos, default)
      end, [MethodContract.new, Contract.new(:number, true), MethodContract.new(true, true)]),

      'at' => MethodType.new('at', lambda do |env, this, index, default|
        index = NumberType.new(0) if index.nil? or index.is_nothing?
        default = get_nothing_type(this.contains) if default.nil?
        retrieve(this, index.get, default)
      end, [MethodContract.new, Contract.new(:number, true), MethodContract.new(true, true)]),

      'first' => MethodType.new('first', lambda do |env, this, index, default|
        index = NumberType.new(0) if index.nil? or index.is_nothing?
        default = get_nothing_type(this.contains) if default.nil?
        retrieve(this, index.get, default)
      end, [MethodContract.new, Contract.new(:number, true), MethodContract.new(true, true)]),

      'last' => MethodType.new('last', lambda do |env, this, index, default|
        index = NumberType.new(0) if index.nil? or index.is_nothing?
        default = get_nothing_type(this.contains) if default.nil?
        pos = this.value.length - 1
        pos -= index.get
        retrieve(this, pos, default)
      end, [MethodContract.new, Contract.new(:number, true), MethodContract.new(true, true)]),

      'range' => MethodType.new('range', lambda do |env, this, pos_start, pos_elems|
        pos_start = 0 if pos_start.is_nothing?
        pos_elems = this.value.length if pos_elems.is_nothing?

        pos_start = [[0, pos_start.get.to_i].max, this.value.length].min
        pos_elems = [[-1 * pos_start - 1, pos_elems.get.to_i].max, this.value.length - pos_start].min

        pos_end = pos_start + pos_elems
        array = if pos_start < pos_end
                  (pos_start...pos_end).to_a
                else
                  (pos_end + 1...pos_start + 1).to_a.reverse
                end
        ArrayType.new(array.map { |x| this.value[x] }, this.contains, this.curr_pos, this.default)
      end, [MethodContract.new, Contract.new(:number), Contract.new(:number)]),

      'reverse' => MethodType.new('reverse', lambda do |env, this|
        ArrayType.new(this.value.reverse, this.contains, this.curr_pos, this.default)
      end, [MethodContract.new]),

      'to_text' => MethodType.new('to_text', lambda do |env, this|
        TextType.new(this.to_s)
      end, [MethodContract.new])

    @stdlib.add_ns 'next', FunctionType.new('next', lambda do |env, array, default|
      check_default_value('next', array, default)
      ArrayType.new(array.value, array.contains, array.curr_pos + 1, default.get)
    end, [AnyArrayContract.new, AnyContract.new])

    @stdlib.add_ns 'prev', FunctionType.new('prev', lambda do |env, array, default|
      check_default_value('prev', array, default)
      ArrayType.new(array.value, array.contains, array.curr_pos - 1, default.get)
    end, [AnyArrayContract.new, AnyContract.new])

    @stdlib.add_ns 'first', FunctionType.new('first', lambda do |env, array, default|
      check_default_value('first', array, default)
      ArrayType.new(array.value, array.contains, 0, default.get)
    end, [AnyArrayContract.new, AnyContract.new])

    @stdlib.add_ns 'last', FunctionType.new('last', lambda do |env, array, default|
      check_default_value('last', array, default)
      ArrayType.new(array.value, array.contains, array.value.length - 1, default.get)
    end, [AnyArrayContract.new, AnyContract.new])
  end
end

FormulaFields.init_array
