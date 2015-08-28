module FormulaFields
  class Environment
    def initialize(read_only = true, parent = nil)
      @class = {}
      @parent = parent
      @read_only = read_only
      @table = {}
    end

    def add_ns(name, hash)
      @table[name] = hash
    end

    def add_class(name, hash)
      @class[name] = hash
    end

    def lookup(name, scope = nil)
      table = scope.nil? ? NamespaceType.new(@table) : scope
      look_result = if !(table.class < BaseType)
                      nil
                    elsif table.type == :namespace
                      table.get[name]
                    else
                      class_lookup = @class[table.type]
                      class_lookup.nil? ? nil : class_lookup[name]
                    end
      if look_result.nil?
        if !@parent.nil? and @scope.nil?
          @parent.lookup(name)
        else
          nil
        end
      elsif look_result.is_a? Hash
        NamespaceType.new(look_result)
      else
        look_result
      end
    end

    def assign(path, value)
      if @table.key? path[0] or path.length == 1
        if @read_only
          fail ReadOnlyError.new(path)
        end

        ns = path[0...-1].reduce @table do |a, e|
          if a.key? e and a[e].is_a? Hash
            a[e]
          else
            fail AssignError.new(path)
          end
        end

        if ns.is_a? Hash
          ns[path[-1]] = value
        else
          fail AssignError.new(path)
        end
      elsif !@parent.nil?
        @parent.assign(path, value)
      else
        fail AssignError.new(path)
      end
    end
  end
end
