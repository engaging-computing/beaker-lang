require 'rltk/lexer'

module FormulaFields
  class Lexer < RLTK::Lexer
    # Whitespace
    rule(/[ \t\r\f]/)
    rule(/\n+/) { |t| [:NEWLINE, t] }

    # Assignment
    rule(/\=/) { |t| [:ASSIGN, t] }

    # Separation
    rule(/\(/) { |t| [:OPENP, t] }
    rule(/\)/) { |t| [:CLOSEP, t] }
    rule(/\./) { |t| [:PERIOD, t] }
    rule(/,/) { |t| [:COMMA, t] }

    # Arithmetic Operators
    rule(/[+-]/) { |t| [:ADDOP, t] }
    rule(/[*\/]/) { |t| [:MULOP, t] }
    rule(/\^/) { |t| [:POWOP, t] }
    rule(/%/) { |t| [:MODOP, t] }

    # Boolean operators
    rule(/\==/) { |t| [:EQUAL, t] }
    rule(/!=/) { |t| [:NEQUAL, t] }
    rule(/</) { |t| [:LT, t] }
    rule(/<=/) { |t| [:LTEQ, t] }
    rule(/>/) { |t| [:GT, t] }
    rule(/>=/) { |t| [:GTEQ, t] }
    rule(/&&/) { |t| [:AND, t] }
    rule(/\|\|/) { |t| [:OR, t] }
    rule(/!/) { |t| [:NOT, t] }

    # Number Literal
    rule(/\d+/) { |t| [:LITERAL, t.to_f] }
    rule(/\d*\.\d+/) { |t| [:LITERAL, t.to_f] }
    rule(/\d+e\d+/) { |t| [:LITERAL, t.to_f] }
    rule(/\d*\.\d+e\d+/) { |t| [:LITERAL, t.to_f] }

    # String Literal
    rule(/"[^"]*"/) { |t| [:LITERAL, t] }
    rule(/'[^']*'/) { |t| [:LITERAL, t] }

    # Identifier
    rule(/[\w_](?:[\w\d_])*/) { |t| [:IDENTIFIER, t] }
  end
end
