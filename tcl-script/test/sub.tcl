set x abc
puts "A simple substitution: $x\n"

set y [set x "def"]
puts "Remember that set returns the new value of the variable:"
puts "    X: $x Y: $y\n"

set b "\[set y {This is a string within braces within quotes}]"
puts $b
