module Beaker
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
      access(@curr_pos, @default).is_nothing?
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
      elsif @value[index].nil? and default.nil?
        Beaker.get_nothing_type(@contains)
      elsif @value[index].nil?
        ArrayType.class_map[@contains].new(default)
      else
        ArrayType.class_map[@contains].new(@value[index])
      end
    end

    def to_s
      packed = @value.map { |x| Beaker.pack_by_type(x, @contains).to_s }
      "[#{packed.join(', ')}]"
    end
  end
end
