module FormulaFields
  class Error < StandardError
    def to_s
      @msg
    end
  end

  class ArgumentTypeError < Error
    attr_reader :expected
    attr_reader :method
    attr_reader :msg
    attr_reader :provided

    def initialize(method, expected, provided)
      @method = method
      @expected = expected
      @provided = provided
      @msg = "In #{method}: expected (#{expected.join(',')}), given (#{provided.join(',')})"
    end
  end

  class ArgumentCountError < Error
    attr_reader :expected
    attr_reader :method
    attr_reader :msg
    attr_reader :provided

    def initialize(method, expected, provided)
      @method = method
      @expected = expected
      @provided = provided
      @msg = "In #{method}: expected up to #{expected} argument(s), given #{provided}"
    end
  end

  class AssignError < Error
    attr_reader :msg
    attr_reader :path

    def initialize(path)
      @path = path
      @msg = "Could not assign to #{path.join ':'}"
    end
  end

  class NameResolutionError < Error
    attr_reader :msg
    attr_reader :name

    def initialize(name)
      @name = name
      @msg = "Unknown identifier #{name}"
    end
  end

  class NotCallableError < Error
    attr_reader :msg
    attr_reader :name
    attr_reader :type

    def initialize(name, type)
      @name = name
      @type = type
      @msg = "#{name} (#{type}) is not a function"
    end
  end

  class ParseError < Error
    attr_reader :line
    attr_reader :msg
    attr_reader :num
    attr_reader :pos
    attr_reader :token

    def initialize(error, line)
      @line = line
      @token = error.current.type
      if @token == :EOS
        @num = error.seen[-1].position.line_number
        @pos = error.seen[-1].position.line_offset + 1
      else
        @num = error.current.position.line_number
        @pos = error.current.position.line_offset
      end

      @msg = "Unexpected token #{@token} at #{@num}:#{@pos + 1}\n  #{line.chomp}\n  #{'~' * @pos}^"
    end
  end

  class ReadOnlyError < Error
    attr_reader :msg
    attr_reader :path

    def initialize(path)
      @path = path
      @msg = "#{path.join ':'} is read only"
    end
  end
end
