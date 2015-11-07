require 'test_helper'

class LexerTest < Minitest::Test
  load_lex_test('./test/files/lexer_simple.txt').each.with_index do |x, i|
    define_method("test_lexer_simple_#{i}") do
      src, res = x
      lex = FormulaFields::Lexer.lex(src)
      assert_same_lex(src, lex, res)
    end
  end

  load_lex_test('./test/files/lexer_greedy.txt').each.with_index do |x, i|
    define_method("test_lexer_greedy_#{i}") do
      src, res = x
      lex = FormulaFields::Lexer.lex(src)
      assert_same_lex(src, lex, res)
    end
  end

  load_lex_test('./test/files/lexer_incorrect.txt', false).each.with_index do |x, i|
    define_method("test_lexer_incorrect_#{i}") do
      passed = false
      begin
        FormulaFields::Lexer.lex(x)
      rescue RLTK::LexingError
        passed = true
      end
      assert passed, "Should not have been able to lex #{x}"
    end
  end
end
