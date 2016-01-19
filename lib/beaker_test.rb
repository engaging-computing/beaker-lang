require './beaker/types'
require './beaker/contract'
require './beaker/lexer'
require './beaker/ast'
require './beaker/parser'
require './beaker/environment'
require './beaker/errors'
require './beaker/stdlib'
require './beaker/stdlib_array'
require './beaker/stdlib_bool'
require './beaker/stdlib_location'
require './beaker/stdlib_math'
require './beaker/stdlib_number'
require './beaker/stdlib_text'
require './beaker/stdlib_timestamp'

require './beaker_code.rb'

include Beaker
include TestCode

Beaker.stdlib.add_ns 'Test',
  'a' => ArrayType.new([1, 2, 3, 4, 5], :number),
  'b' => ArrayType.new(['a', 'b', 'c'], :text),
  'c' => ArrayType.new([30, 60, 90, 120, 150], :latitude),
  'd' => ArrayType.new([45, 90, 135, 180, 225, 270], :longitude),
  'e' => ArrayType.new([
    DateTime.new(2015, 1, 1, 1, 1, 1),
    DateTime.new(2016, 1, 1, 1, 1, 1),
    DateTime.new(2017, 1, 1, 1, 1, 1),
    DateTime.new(2018, 1, 1, 1, 1, 1),
    DateTime.new(2019, 1, 1, 1, 1, 1)
  ], :timestamp),
  'x1' => LongitudeType.new(75),
  'x2' => LongitudeType.new(0),
  'y1' => LatitudeType.new(0),
  'y2' => LatitudeType.new(90),
  'y3' => LatitudeType.new(75),
  't1' => TimestampType.new('2015/8/24 9:31:00'),
  't2' => TimestampType.new('2015/8/24 17:31:00'),
  't3' => TimestampType.new('2015/8/25 9:31:00'),
  't4' => TimestampType.new('2015/8/25 17:31:00'),
  't5' => TimestampType.new('2015/8/26 13:41:32')

Beaker.stdlib.add_ns '*', NumberType.new(1)

TestCode.code.each.with_index do |x, i|
  failed = false
  output = false
  lisp = false

  l = Lexer.lex(x[0])

  begin
    p = if output
          Parser.parse(l, parse_tree: File.open("graphs/#{i}.dot", 'w'))
        else
          Parser.parse(l, verbose: false)
        end

    if lisp
      p.each { |y| puts y.to_s }
    end

    a = p.map { |y| y.evaluate(Beaker.stdlib) } [-1]
  rescue Error => e
    puts e.msg
    failed = true
  end

  if !failed and !a.nil? and (a.type != x[1].type or a.get != x[1].get)
    puts "#{x[0]} => #{a.get} (should have been #{x[1].get})\n\n"
  end
end
