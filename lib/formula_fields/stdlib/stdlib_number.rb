module FormulaFields
  def self.init_number
    # Take an arbitrary type and convert it into a number.  Booleans are converted
    #   into a 1 if true, and 0 if false.  An attempt is made to parse text types
    #   into numbers, but if it fails, the nil type is returned.  Timestamps
    #   return the unix timestamp.  Latitude and longitude return their values in
    #   degress.  Everything else is a nil type.
    @stdlib.add 'number', FunctionType.new('number', lambda do |env, x|
      if x.get.nil?
        # so strftime doesn't implode
        NumberType.new(nil)
      else
        type = x.type == :array ? x.contains : x.type
        case type
        when :bool then NumberType.new(x.get ? 1 : 0)
        when :number then NumberType.new(x.get)
        when :text then NumberType.fromText(x)
        when :timestamp then NumberType.new(x.get.strftime('%s').to_i)
        when :latitude then NumberType.new(x.get)
        when :longitude then NumberType.new(x.get)
        else NumberType.new(nil)
        end
      end
    end, [OrContract.new([
      Contract.new(:bool),
      Contract.new(:number),
      Contract.new(:text),
      Contract.new(:timestamp),
      Contract.new(:latitude),
      Contract.new(:longitude)])])
  end
end

FormulaFields.init_number
