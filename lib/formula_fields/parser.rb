require 'rltk/parser'

module FormulaFields
  class Parser < RLTK::Parser
    def self.parse(line, tokens, opts = {})
      super(tokens, opts)
    rescue RLTK::NotInLanguage => e
      raise ParseError.new(e, line)
    end

    production(:andexpr) do
      clause('orexpr') { |x| x }
      clause('.andexpr NEWLINE* AND NEWLINE* .orexpr') { |x, z| And.new(x, z) }
    end

    production(:orexpr) do
      clause('eqexpr') { |x| x }
      clause('.orexpr NEWLINE* OR NEWLINE* .eqexpr') { |x, z| Or.new(x, z) }
    end

    production(:eqexpr) do
      clause('addexpr') { |x| x }
      clause('.eqexpr NEWLINE* EQUAL NEWLINE* .addexpr') { |x, y| Equal.new(x, y) }
      clause('.eqexpr NEWLINE* NEQUAL NEWLINE* .addexpr') { |x, y| NotEqual.new(x, y) }
      clause('.eqexpr NEWLINE* LT NEWLINE* .addexpr') { |x, y| LessThan.new(x, y) }
      clause('.eqexpr NEWLINE* LTEQ NEWLINE* .addexpr') { |x, y| LessThanEqual.new(x, y) }
      clause('.eqexpr NEWLINE* GT NEWLINE* .addexpr') { |x, y| GreaterThan.new(x, y) }
      clause('.eqexpr NEWLINE* GTEQ NEWLINE* .addexpr') { |x, y| GreaterThanEqual.new(x, y) }
    end

    production(:addexpr) do
      clause('modexpr') { |x| x }
      clause('.addexpr NEWLINE* .ADDOP NEWLINE* .modexpr') { |x, op, y| op == '+' ? Add.new(x, y) : Sub.new(x, y) }
    end

    production(:modexpr) do
      clause('mulexpr') { |x| x }
      clause('.modexpr NEWLINE* MODOP NEWLINE* .mulexpr') { |x, y| Mod.new(x, y) }
    end

    production(:mulexpr) do
      clause('powexpr') { |x| x }
      clause('.mulexpr NEWLINE* .MULOP NEWLINE* .powexpr') { |x, op, y| op == '*' ? Mul.new(x, y) : Div.new(x, y) }
    end

    production(:powexpr) do
      clause('notexpr') { |x| x }
      clause('.notexpr NEWLINE* POWOP NEWLINE* .powexpr') { |x, y| Pow.new(x, y) }
    end

    production(:notexpr) do
      clause('signexpr') { |x| x }
      clause('NOT NEWLINE* .notexpr') { |x| Not.new(x) }
    end

    production(:signexpr) do
      clause('callexpr') { |x| x }
      clause('.ADDOP NEWLINE* .signexpr') { |op, x| op == '+' ? x : Mul.new(NumberLiteral.new(Float(-1)), x) }
    end

    production(:callexpr) do
      clause('resexpr') { |x| x }
      clause('.callexpr NEWLINE* .argmt') { |x, y| Call.new(x, y) }
    end

    production(:resexpr) do
      clause('identexpr') { |x| x }
      clause('.callexpr NEWLINE* PERIOD NEWLINE* .identexpr') { |x, y| Resolve.new(x, y) }
    end

    production(:identexpr) do
      clause('IDENTIFIER') { |x| Name.new(x) }
      #clause('OPENP NEWLINE* .assexpr NEWLINE* CLOSEP') { |x| x }
      clause('LITERAL') { |x| x.is_a?(Numeric) ? NumberLiteral.new(Float(x)) : StringLiteral.new(String(x)) }
    end

    production(:argmt) do
      clause('OPENP NEWLINE* .andexpr NEWLINE* .arest NEWLINE* CLOSEP') { |x, y| [x] + y }
      clause('OPENP NEWLINE* .andexpr NEWLINE* CLOSEP') { |x| [x] }
      clause('OPENP NEWLINE* CLOSEP') { |_, _, _| [] }
    end

    production(:arest) do
      clause('COMMA NEWLINE* .andexpr NEWLINE* .arest') { |x, y| [x] + y }
      clause('COMMA NEWLINE* .andexpr') { |x| [x] }
    end

    finalize
  end
end
