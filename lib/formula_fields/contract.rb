module FormulaFields
  def self.build_type_label(object)
    object.type == :array ? [object.contains] : object.type
  end

  def self.match(object, type)
    if object.type == :array and type == :array
      true
    elsif object.type == :array and type.is_a? Array
      type == [object.contains]
    elsif object.type == :array
      type == object.contains
    else
      type == object.type
    end
  end

  class BaseContract; end

  class Contract < BaseContract
    def initialize(type, optional = false)
      @type = type
      @optional = optional
    end

    def check?(object)
      if object.nil?
        @optional
      else
        FormulaFields.match(object, @type)
      end
    end

    def to_s
      base = nil
      if @type.is_a? Array
        base = "[#{@type[0]}]"
      else
        base = @type.to_s
      end
      if @optional
        base += '?'
      end
      base
    end
  end

  class MethodContract < BaseContract
    def initialize(inner = false, optional = false)
      @inner = inner
      @optional = optional
    end

    def check?(object)
      this = yield
      if object.nil?
        @optional
      elsif @inner and this.type != :array
        false
      elsif @inner and this.type == :array
        FormulaFields.match(object, this.contains)
      else
        FormulaFields.build_type_label(this) == FormulaFields.build_type_label(object)
      end
    end

    def to_s
      base = 'self'
      if @optional
        base += '?'
      end
      if @inner
        base = '*' + base
      end
      base
    end
  end

  class OrContract < BaseContract
    def initialize(contracts, optional = false)
      @contracts = contracts
      @optional = optional
    end

    def check?(object)
      this = yield
      if object.nil?
        @optional
      else
        match = @contracts.select do |x|
          x.check?(object) { this }
        end
        match.length > 0
      end
    end

    def to_s
      contract_str = @contracts.map(&:to_s)
      "{#{contract_str.join '|'}}"
    end
  end

  class AnyContract < BaseContract
    def initialize(optional = false)
      @optional = optional
    end

    def check?(object)
      object.nil? ? @optional : true
    end

    def to_s
      'any'
    end
  end

  class AnyArrayContract < BaseContract
    def initialize(optional = false)
      @optional = optional
    end

    def check?(object)
      object.nil? ? @optional : object.type == :array
    end

    def to_s
      'array'
    end
  end
end
