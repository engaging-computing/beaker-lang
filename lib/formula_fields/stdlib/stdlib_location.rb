module FormulaFields
  def self.init_location
    # Take an arbitrary type and convert it into a latitude.  An attempt is made
    #   to parse text values as numbers, which are then converted to latitudes.
    #   If this fails, a latitude nothing type is made.  Number types are simply
    #   passed to the constructor.  Everything else is a nil type.
    @stdlib.add 'latitude', FunctionType.new('latitude', lambda do |env, x|
      type = x.type == :array ? x.contains : x.type
      case type
      when :number then LatitudeType.new(x.get)
      when :text then LatitudeType.fromText(x)
      when :latitude then LatitudeType.new(x.get)
      else LatitudeType.new(nil)
      end
    end, [OrContract.new([Contract.new(:number), Contract.new(:text), Contract.new(:latitude)])])

    # Take an arbitrary type and convert it into a longitude.  An attempt is made
    #   to parse text values as numbers, which are then converted to longitudes.
    #   If this fails, a longitude nothing type is made.  Number types are simply
    #   passed to the constructor.  Everything else is a nil type.
    @stdlib.add 'longitude', FunctionType.new('longitude', lambda do |env, x|
      type = x.type == :array ? x.contains : x.type
      case type
      when :number then LongitudeType.new(x.get)
      when :text then LongitudeType.fromText(x)
      when :longitude then LongitudeType.new(x.get)
      else LongitudeType.new(nil)
      end
    end, [OrContract.new([Contract.new(:number), Contract.new(:text), Contract.new(:longitude)])])

    # Takes a latitude and longitude type, and returns a location type.
    @stdlib.add 'location', FunctionType.new('location', lambda do |env, x, y|
      LocationType.new(x.get, y.get)
    end, [Contract.new(:longitude), Contract.new(:latitude)])

    @stdlib.add 'degrees', FunctionType.new('degrees', lambda do |env, x|
      NumberType.new(x.get)
    end, [OrContract.new([Contract.new(:latitude), Contract.new(:longitude)])])

    @stdlib.add 'radians', FunctionType.new('radians', lambda do |env, x|
      if x.is_nothing?
        NumberType.new(nil)
      else
        NumberType.new(x.get * Math::PI / 180)
      end
    end, [OrContract.new([Contract.new(:latitude), Contract.new(:longitude)])])
  end
end

FormulaFields.init_location
