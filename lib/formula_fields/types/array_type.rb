module FormulaFields
  class ArrayType < BaseType
    def self.class_map
      {
        number: NumberType,
        text: TextType,
        latitude: LatitudeType,
        longitude: LongitudeType,
        timestamp: TimestampType
      }
    end

    attr_accessor :curr_pos
    attr_reader :contains
    attr_reader :default

    def initialize(array, contains, curr_pos = 0, default = nil)
      super(array)
      @contains = contains
      @curr_pos = curr_pos
      @default = default
    end

    def is_nothing?
      @value.length == 0
    end

    def type
      :array
    end

    def get
      access(@curr_pos, @default).get
    end

    def access(index, default = nil)
      if index < 0 or index >= @value.length
        ArrayType.class_map[@contains].new(default)
      else
        tmp = ArrayType.class_map[@contains].new(@value[index])
        if tmp.is_nothing?
          ArrayType.class_map[@contains].new(default)
        else
          tmp
        end
      end
    end

    def to_s
      packed = @value.map { |x| FormulaFields.pack_by_type(x, @contains).to_s }
      "[#{packed.join(', ')}]"
    end
  end
end
