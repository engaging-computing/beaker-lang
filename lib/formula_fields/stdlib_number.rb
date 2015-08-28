module FormulaFields
  def self.init_number
    @stdlib.add_class :number,
      'to_text' => MethodType.new('to_text', lambda do |env, this|
        TextType.new(this.to_s)
      end, [MethodContract.new]),
      'to_timestamp' => MethodType.new('to_timestamp', lambda do |env, this|
        TimestampType.new(DateTime.strptime(this.get.to_i.to_s, '%s'))
      end, [MethodContract.new]),
      'to_latitude' => MethodType.new('to_latitude', lambda do |env, this|
        LatitudeType.new(this.get)
      end, [MethodContract.new]),
      'to_latitude_degrees' => MethodType.new('to_latitude_degrees', lambda do |env, this|
        LatitudeType.new(this.get)
      end, [MethodContract.new]),
      'to_latitude_radians' => MethodType.new('to_latitude_radians', lambda do |env, this|
        LatitudeType.new(this.get * 180 / Math::PI)
      end, [MethodContract.new]),
      'to_longitude' => MethodType.new('to_longitude', lambda do |env, this|
        LongitudeType.new(this.get)
      end, [MethodContract.new]),
      'to_longitude_degrees' => MethodType.new('to_longitude_degrees', lambda do |env, this|
        LongitudeType.new(this.get)
      end, [MethodContract.new]),
      'to_longitude_radians' => MethodType.new('to_longitude_radians', lambda do |env, this|
        LongitudeType.new(this.get * 180 / Math::PI)
      end, [MethodContract.new])
  end
end

FormulaFields.init_number
