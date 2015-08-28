module FormulaFields
  def retrieve(array, pos, default)
    if pos >= 0 and pos < array.get.length
      if array.get[pos].nil?
        default
      else
        pack_by_type(array.get[pos], array.contains)
      end
    else
      default
    end
  end

  def self.init_array
    @stdlib.add_class :array,
      'type' => MethodType.new('type', lambda do |env, this|
        TextType.new(this.contains.to_s.capitalize)
      end, [MethodContract.new]),

      'length' => MethodType.new('length', lambda do |env, this|
        NumberType.new(this.get.length)
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
        pos = this.get.length - 1
        pos -= index.get
        retrieve(this, pos, default)
      end, [MethodContract.new, Contract.new(:number, true), MethodContract.new(true, true)]),

      'range' => MethodType.new('range', lambda do |env, this, pos_start, pos_elems|
        pos_start = 0 if pos_start.is_nothing?
        pos_elems = this.get.length if pos_elems.is_nothing?

        pos_start = [[0, pos_start.get.to_i].max, this.get.length].min
        pos_elems = [[-1 * pos_start - 1, pos_elems.get.to_i].max, this.get.length - pos_start].min

        pos_end = pos_start + pos_elems
        array = if pos_start < pos_end
                  (pos_start ... pos_end).to_a
                else
                  (pos_end + 1 ... pos_start + 1).to_a.reverse
                end
        ArrayType.new(array.map { |x| this.get[x] }, this.contains)
      end, [MethodContract.new, Contract.new(:number), Contract.new(:number)]),

      'reverse' => MethodType.new('reverse', lambda do |env, this|
        ArrayType.new(this.get.reverse, this.contains)
      end, [MethodContract.new]),

      'to_text' => MethodType.new('to_text', lambda do |env, this|
        TextType.new(this.to_s)
      end, [MethodContract.new])

    @stdlib.add_ns 'Array',
      'repeat' => FunctionType.new('repeat', lambda do |env, item, times|
        ArrayType.new([item.get] * times.get.to_i, item.type)
      end, [OrContract.new([
        Contract.new(:number),
        Contract.new(:text),
        Contract.new(:latitude),
        Contract.new(:longitude),
        Contract.new(:timestamp)
      ]), Contract.new(:number)]),

      'count' => FunctionType.new('count', lambda do |env, start, times|
        start = NumberType.new(0) if start.is_nothing?
        if times.is_nothing?
          ArrayType.new([], :number)
        else
          basic_array = if times.get > 0
                          (0 ... times.get.to_i).to_a
                        elsif times.get < 0
                          (times.get.to_i + 1 ... 1).to_a.reverse
                        else
                          []
                        end
          ArrayType.new(basic_array.map { |x| start.get + x }, :number)
        end
      end, [Contract.new(:number), Contract.new(:number)])
  end
end

FormulaFields.init_array
