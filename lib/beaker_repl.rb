require 'beaker'

include Beaker

Beaker.add_test_vars(Beaker.stdlib)
Beaker.stdlib.add '*', NumberType.new(1)

curr_env = Environment.new(false, Beaker.stdlib)

loop do
  print '> '
  $stdout.flush

  input = gets
  break if input.nil?

  begin
    l = Lexer.lex(input.chomp)
  rescue => e
    puts "Lexer error: #{e}"
    next
  end

  begin
    p = Parser.parse(input.chomp, l, verbose: false)
  rescue RLTK::NotInLanguage => e
    puts ParseError.new(e, input)
    next
  rescue ParseError => e
    puts e
    next
  rescue => e
    puts "Unknown parse error #{e}"
    next
  end

  puts "  => #{p}"

  begin
    a = p.evaluate(curr_env)
  rescue Beaker::Error => e
    puts e
    next
  rescue => e
    puts "Unknown evaluation error: #{e.inspect}"
    next
  end

  puts "  => #{a} (#{a.type})"
end
