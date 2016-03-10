module Beaker
  # the nothing type is a special case of the general idea of nothing
  # this handles the case were the resulting value of an expression is nothing,
  #   but no type information can be determined
  # this edge case arises solely when a string isomorphic to the empty string is
  #   parsed
  # furthermore, this allows empty strings to work as an expression for any
  #   desired result type
  class NothingType < BaseType
    def initialize
      super(nil)
    end

    def type
      :nothing
    end
  end
end
