module Beaker
  class NamespaceType < BaseType
    def type
      :namespace
    end

    def to_s
      '<...>'
    end
  end
end
