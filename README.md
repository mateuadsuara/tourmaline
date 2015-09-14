#Tourmaline
[![Gem Version](https://badge.fury.io/rb/tourmaline.svg)](http://badge.fury.io/rb/tourmaline)

![Tourmaline logo](https://raw.githubusercontent.com/demonh3x/tourmaline/master/img/logo200.jpg)

A configurable ruby interpreter for the command line

### Setup
`gem install tourmaline`

### Examples
`ping www.google.com | rb 'lines.include?("time=").split("time=")[1].puts.each'`

`echo -e '1\n5\n3\n7\n' | rb 'puts lines.to_i.take(3).inject(:+)'`

`rb 'lines.upcase.take_while{|l| !l.include?("QUIT")}.puts.each'`

`rb 'doing{rand(1..6)}.print.each'`
