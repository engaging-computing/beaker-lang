module FormulaFields
  def self.init_text
    @stdlib.add_class :text,
      'length' => MethodType.new('length', lambda do |env, this|
        NumberType.new(this.get.length)
      end, [MethodContract.new]),
      'capitalize' => MethodType.new('capitalize', lambda do |env, this|
        TextType.new(this.get.capitalize)
      end, [MethodContract.new]),
      'uppercase' => MethodType.new('uppercase', lambda do |env, this|
        TextType.new(this.get.upcase)
      end, [MethodContract.new]),
      'lowercase' => MethodType.new('lowercase', lambda do |env, this|
        TextType.new(this.get.downcase)
      end, [MethodContract.new]),
      'swapcase' => MethodType.new('swapcase', lambda do |env, this|
        TextType.new(this.get.swapcase)
      end, [MethodContract.new]),
      'reverse' => MethodType.new('reverse', lambda do |env, this|
        TextType.new(this.get.reverse)
      end, [MethodContract.new]),
      'trim' => MethodType.new('trim', lambda do |env, this|
        TextType.new(this.get.strip)
      end, [MethodContract.new]),
      'substring' => MethodType.new('substring', lambda do |env, this, spos, epos|
        min_len = 0
        max_len = this.get.length
        spos = NumberType.new(min_len) if spos.is_nothing? or spos.get < min_len
        epos = NumberType.new(max_len) if epos.is_nothing? or epos.get > max_len
        TextType.new(this.get[spos.get, epos.get - spos.get])
      end, [MethodContract.new, Contract.new(:number), Contract.new(:number)]),
      'to_number' => MethodType.new('to_number', lambda do |env, this, fval|
        begin
          NumberType.new(Float(this.get))
        rescue
          if fval.nil?
            NumberType.new(nil)
          else
            fval
          end
        end
      end, [MethodContract.new, Contract.new(:number, true)]),
      'to_timestamp' => MethodType.new('to_timestamp', lambda do |env, this, fval|
        date = begin
          DateTime.parse(this.get)
        rescue
          fval.nil? ? nil : fval.get
        end
        TimestampType.new(date)
      end, [MethodContract.new, Contract.new(:timestamp, true)]),
      'to_latitude' => MethodType.new('to_latitude', lambda do |env, this, fval|
        lat = begin
          Float(this.get)
        rescue
          fval.nil? ? nil : fval.get
        end
        LatitudeType.new(lat)
      end, [MethodContract.new, Contract.new(:latitude, true)]),
      'to_longitude' => MethodType.new('to_longitude', lambda do |env, this, fval|
        lon = begin
          Float(this.get)
        rescue
          fval.nil? ? nil : fval.get
        end
        LongitudeType.new(lon)
      end, [MethodContract.new, Contract.new(:longitude, true)])
  end
end

FormulaFields.init_text
