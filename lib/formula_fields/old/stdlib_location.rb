module FormulaFields
  def self.init_location
    @stdlib.add_class :latitude,
      'to_number' => MethodType.new('to_number', lambda do |env, this|
        NumberType.new(this.get)
      end, [MethodContract.new]),
      'to_degrees' => MethodType.new('to_degrees', lambda do |env, this|
        NumberType.new(this.get)
      end, [MethodContract.new]),
      'to_radians' => MethodType.new('to_radians', lambda do |env, this|
        NumberType.new(this.to_rad)
      end, [MethodContract.new]),
      'to_text' => MethodType.new('to_text', lambda do |env, this|
        TextType.new(this.to_s)
      end, [MethodContract.new])

    @stdlib.add_class :longitude,
      'to_number' => MethodType.new('to_number', lambda do |env, this|
        NumberType.new(this.get)
      end, [MethodContract.new]),
      'to_degrees' => MethodType.new('to_degrees', lambda do |env, this|
        NumberType.new(this.get)
      end, [MethodContract.new]),
      'to_radians' => MethodType.new('to_radians', lambda do |env, this|
        NumberType.new(this.to_rad)
      end, [MethodContract.new]),
      'to_text' => MethodType.new('to_text', lambda do |env, this|
        TextType.new(this.to_s)
      end, [MethodContract.new])

    @stdlib.add_ns 'Location',
      'distance' => FunctionType.new('distance', lambda do |env, x1t, y1t, x2t, y2t|
        if x1t.is_nothing? or y1t.is_nothing? or x2t.is_nothing? or y2t.is_nothing?
          NumberType.new(nil)
        else
          x1 = x1t.to_rad
          x2 = x2t.to_rad
          dx = x2 - x1

          y1 = y1t.to_rad
          y2 = y2t.to_rad
          dy = y2 - y1

          a = (Math.sin(dy / 2)**2) + Math.cos(y1) * Math.cos(y2) * (Math.sin(dx / 2)**2)
          c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

          NumberType.new(c)
        end
      end, [Contract.new(:longitude), Contract.new(:latitude), Contract.new(:longitude), Contract.new(:latitude)])
  end
end

FormulaFields.init_location
