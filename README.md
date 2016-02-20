#Tourmaline
[![Gem Version](https://badge.fury.io/rb/tourmaline.svg)](http://badge.fury.io/rb/tourmaline)

![Tourmaline logo](https://raw.githubusercontent.com/mateuadsuara/tourmaline/master/img/logo200.jpg)

A configurable ruby interpreter for the command line

### Setup
`gem install tourmaline`

### Plugins
Tourmaline's functionality can be extended via ruby scripts (`*.rb` files). Just place them inside the `~/.tourmaline/lib` folder.

As an example, create the file `~/.tourmaline/lib/plugin_file.rb` with the code:
```ruby
def execute_plugin
  puts "plugin executed!"
end
```

Given that, you will be able to run `rb 'execute_plugin'`

### Examples

#### Show only the time of each ping

`ping www.google.com | rb 'lines.include?("time=").split("time=")[1].puts'`

Vanilla ruby:

`ping www.google.com | ruby -e 'STDIN.each_line.lazy.select{|l| l.include?("time=")}.map{|l| l.split("time=")[1]}.each{|l| puts l}'`

#### Sum the first three numbers

`echo -e '1\n5\n3\n7\n' | rb 'lines.take(3).to_i.inject(:+).puts'`

Vanilla ruby:

`echo -e '1\n5\n3\n7\n' | ruby -e 'puts STDIN.each_line.take(3).map{|l| l.to_i}.inject(:+)'`

#### Echo until "quit" is entered

`rb 'lines.take_while{|l|l!="quit"}.puts'`

Vanilla ruby:

`ruby -e 'STDIN.each_line.lazy.take_while{|l| l.chomp!="quit"}.each{|l| puts l}'`

#### Play rock, paper, scissors

`rb 'doing{["rock", "paper", "scissors"].sample}.take(2).puts'`

Vanilla ruby:

`ruby -e '2.times{puts ["rock", "paper", "scissors"].sample}'`
