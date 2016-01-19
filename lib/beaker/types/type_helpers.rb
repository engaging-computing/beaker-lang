module Beaker
  def self.inner_type(value)
    value.type == :array ? value.contains : value.type
  end

  def self.get_nothing_type(type_label)
    case type_label
    when :number then NumberType.new(nil)
    when :text then TextType.new('')
    when :latitude then LatitudeType.new(nil)
    when :longitude then LongitudeType.new(nil)
    when :timestamp then TimestampType.new(nil)
    end
  end

  def self.pack_by_type(value, type_label)
    case type_label
    when :number then NumberType.new(value)
    when :text then TextType.new(value)
    when :latitude then LatitudeType.new(value)
    when :longitude then LongitudeType.new(value)
    when :timestamp then TimestampType.new(value)
    end
  end
end
