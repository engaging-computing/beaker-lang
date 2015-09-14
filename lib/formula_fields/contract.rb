module FormulaFields
  def self.build_type_label(object)
    object.type == :array ? [object.contains] : object.type
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
        FormulaFields::build_type_label(object) == @type
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
        this.contains == build_type_label(object)
      else
        FormulaFields::build_type_label(this) == FormulaFields::build_type_label(object)
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
      if object.nil?
        @optional
      else
        true
      end
    end

    def to_s
      'any'
    end
  end
end
