module FormulaFields
  class FunctionType < BaseType
    def initialize(name, func, contract)
      super(func)
      @name = name
      @contract = contract
    end

    def type
      :function
    end

    def call(env, args)
      if !correct_arg_count?(args)
        # eventually should throw argument count error
        if is_method?
          fail ArgumentCountError.new(@name, @contract.length - 1, args.length - 1)
        else
          fail ArgumentCountError.new(@name, @contract.length, args.length)
        end
      elsif !follows_contract?(args)
        contract_types = @contract.map(&:to_s)
        arg_types = args.map { |x| x.type.to_s }
        fail ArgumentTypeError.new(@name, contract_types, arg_types)
      else
        @value.call(env, *(args + [nil] * (@contract.length - args.length)))
      end
    end

    def is_method?
      false
    end

    private

    def correct_arg_count?(args)
      args.length <= @contract.length
    end

    def follows_contract?(args)
      pairs = @contract.zip(args).select do |x|
        contract, argument = x
        !contract.check?(argument) do
          @this
        end
      end

      pairs.length == 0
    end

    def to_s
      "<#{@name}>"
    end
  end
end
