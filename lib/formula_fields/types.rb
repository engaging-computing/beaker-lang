require 'date'

module FormulaFields
  class BaseType
    def initialize(value)
      @value = value
    end

    def is_nothing?
      @value.nil?
    end

    def can_eq?
      false
    end

    def can_ord?
      false
    end

    def get
      @value
    end

    def to_s
      if self.is_nothing?
        ''
      else
        @value.to_s
      end
    end
  end

  class NumberType < BaseType
    def initialize(value)
      if value.nil?
        super(nil)
      else
        super(Float(value))
      end
    end

    def type
      :number
    end

    def can_eq?
      true
    end

    def eq(r, sym)
      cmp_val = (@value - r.get).abs
      delta = 1e-10
      case sym
      when :eq then cmp_val < delta
      when :ne then cmp_val >= delta
      end
    end

    def can_ord?
      true
    end

    def ord(r, sym)
      l_val = is_nothing? ? 0 : @value
      r_val = r.is_nothing? ? 0 : r.get

      case sym
      when :lt then l_val < r_val
      when :le then l_val <= r_val
      when :gt then l_val > r_val
      when :ge then l_val >= r_val
      end
    end

    def self.arithmetic(op, l, r)
      if l.is_nothing? or r.is_nothing?
        NumberType.new(nil)
      else
        x = case op
            when :add then l.get + r.get
            when :sub then l.get - r.get
            when :mul then l.get * r.get
            when :div then l.get / r.get
            when :mod then l.get % r.get
            when :pow then l.get**r.get
            end
        if x == Float::INFINITY
          NumberType.new(nil)
        else
          NumberType.new(x)
        end
      end
    end
  end

  class TextType < BaseType
    def initialize(value)
      super(value.to_s)
    end

    def is_nothing?
      @value.empty?
    end

    def type
      :text
    end

    def can_eq?
      true
    end

    def eq(r, sym)
      case sym
      when :eq then @value == r.get
      when :ne then @value != r.get
      end
    end

    def can_ord?
      true
    end

    def ord(r, sym)
      case sym
      when :lt then @value < r.get
      when :le then @value <= r.get
      when :gt then @value > r.get
      when :ge then @value >= r.get
      end
    end

    def self.concatenate(l, r)
      temp_l = l.get.to_s
      temp_r = r.get.to_s
      TextType.new(temp_l + temp_r)
    end

    def self.repeat(l, r)
      if r.is_nothing?
        TextType.new('')
      else
        sign = [1, 1, -1][r.get <=> 0]
        base = r.get.abs.floor
        part = r.get.abs - base

        newstr = l.get * base + l.get[0, (l.get.length * part).round]
        if sign == 1
          TextType.new(newstr)
        else
          TextType.new(newstr.reverse)
        end
      end
    end
  end

  class BooleanType < BaseType
    def initialize(value)
      if value.is_a? TrueClass
        super(true)
      else
        super(false)
      end
    end

    def is_nothing?
      false
    end

    def type
      :bool
    end

    def can_eq?
      true
    end

    def eq(r, sym)
      case sym
      when :eq then @value == r.get
      when :ne then @value != r.get
      end
    end

    def to_s
      if @value
        'True'
      else
        'False'
      end
    end
  end

  class TimestampType < BaseType
    def initialize(value)
      if value.is_a? DateTime
        super(value)
      elsif value.is_a? String
        date = begin
          DateTime.parse(value)
        rescue
          nil
        end
        super(date)
      else
        super(nil)
      end
    end

    def type
      :timestamp
    end

    def can_eq?
      true
    end

    def eq(r, sym)
      case sym
      when :eq then (@value <=> r.get) == 0
      when :ne then (@value <=> r.get) != 0
      end
    end

    def can_ord?
      true
    end

    def ord(r, sym)
      case sym
      when :lt then (@value <=> r.get) < 0
      when :le then (@value <=> r.get) <= 0
      when :gt then (@value <=> r.get) > 0
      when :ge then (@value <=> r.get) >= 0
      end
    end

    def to_s
      if self.is_nothing?
        ''
      else
        @value.strftime('%Y/%m/%d %H:%M:%S')
      end
    end
  end

  class LatitudeType < BaseType
    def initialize(value)
      if value.nil?
        super(nil)
      else
        # this is bit is more complicated that it should be because the eq used
        # for wrapping the coords turns 90 degrees into -90 for latitude and
        # 180 into -180 for longitude
        num = Float(value)
        num_mod = ((num + 90) % 180 - 90).abs
        if num < 0
          super(-1 * num_mod)
        else
          super(num_mod)
        end
      end
    end

    def type
      :latitude
    end

    def can_eq?
      true
    end

    def eq(r, sym)
      cmp_val = (@value - r.get).abs
      delta = 1e-10
      case sym
      when :eq then cmp_val < delta
      when :ne then cmp_val >= delta
      end
    end

    def can_ord?
      true
    end

    def ord(r, sym)
      case sym
      when :lt then @value < r.get
      when :le then @value <= r.get
      when :gt then @value > r.get
      when :ge then @value >= r.get
      end
    end

    def to_rad
      @value * Math::PI / 180
    end
  end

  class LongitudeType < BaseType
    def initialize(value)
      if value.nil?
        super(nil)
      else
        num = Float(value)
        num_mod = (num + 180) % 360 - 180
        super(num_mod)
      end
    end

    def type
      :longitude
    end

    def can_eq?
      true
    end

    def eq(r, sym)
      cmp_val = (@value - r.get).abs
      delta = 1e-10
      case sym
      when :eq then cmp_val < delta
      when :ne then cmp_val >= delta
      end
    end

    def can_ord?
      true
    end

    def ord(r, sym)
      case sym
      when :lt then @value < r.get
      when :le then @value <= r.get
      when :gt then @value > r.get
      when :ge then @value >= r.get
      end
    end

    def to_rad
      @value * Math::PI / 180
    end
  end

  class FunctionType < BaseType
    def initialize(name, func, contract)
      super(func)
      @name = name
      @contract = contract
    end

    def type
      :function
    end

    def call(env, args)
      if !correct_arg_count?(args)
        # eventually should throw argument count error
        if is_method?
          fail ArgumentCountError.new(@name, @contract.length - 1, args.length - 1)
        else
          fail ArgumentCountError.new(@name, @contract.length, args.length)
        end
      elsif !follows_contract?(args)
        contract_types = @contract.map(&:to_s)
        arg_types = args.map { |x| x.type.to_s }
        fail ArgumentTypeError.new(@name, contract_types, arg_types)
      else
        @value.call(env, *(args + [nil] * (@contract.length - args.length)))
      end
    end

    def is_method?
      false
    end

    private

    def correct_arg_count?(args)
      args.length <= @contract.length
    end

    def follows_contract?(args)
      pairs = @contract.zip(args).select do |x|
        contract, argument = x
        !contract.check?(argument) do
          @this
        end
      end

      pairs.length == 0
    end

    def to_s
      "<#{@name}>"
    end
  end

  class MethodType < FunctionType
    def initialize(name, func, contract)
      super(name, func, contract)
      @this = nil
    end

    def parent(this)
      @this = this
    end

    def call(env, args)
      super(env, [@this] + args)
    end

    def is_method?
      true
    end
  end

  class ArrayType < BaseType
    @class_map = {
      number: NumberType,
      text: TextType,
      latitude: LatitudeType,
      longitude: LongitudeType,
      timestamp: TimestampType
    }

    def initialize(array, contains)
      super(array)
      @contains = contains
    end

    def is_nothing?
      @value.length == 0
    end

    def type
      :array
    end

    def contains
      @contains
    end

    def access(index, default = nil)
      if index < 0 or index >= @value.length
        @class_map[@inner_type].new(default)
      else
        tmp = @class_map[@inner_type].new(@value[index])
        if tmp.is_nothing?
          @class_map[@inner_type].new(default)
        else
          tmp
        end
      end
    end

    def to_s
      packed = @value.map do |x|
        pack_by_type(x, @contains).to_s
      end
      "[#{packed.join(', ')}]"
    end
  end

  class NamespaceType < BaseType
    def type
      :namespace
    end

    def to_s
      '<...>'
    end
  end

  def get_nothing_type(type_label)
    case type_label
    when :number then NumberType.new(nil)
    when :text then TextType.new('')
    when :latitude then LatitudeType.new(nil)
    when :longitude then LongitudeType.new(nil)
    when :timestamp then TimestampType.new(nil)
    end
  end

  def pack_by_type(value, type_label)
    case type_label
    when :number then NumberType.new(value)
    when :text then TextType.new(value)
    when :latitude then LatitudeType.new(value)
    when :longitude then LongitudeType.new(value)
    when :timestamp then TimestampType.new(value)
    end
  end
end
