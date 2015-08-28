module FormulaFields
  def self.init_bool
    @stdlib.add_class :bool,
      'to_number' => MethodType.new('to_number', lambda do |env, this|
        if this.get
          NumberType.new(1)
        else
          NumberType.new(0)
        end
      end, [MethodContract.new]),
      'to_text' => MethodType.new('to_text', lambda do |env, this|
        TextType.new(this.to_s)
      end, [MethodContract.new])
  end
end

FormulaFields.init_bool
