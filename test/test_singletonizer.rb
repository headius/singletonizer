require 'singletonizer'

class String
  include Singletonizer
end

a = 'yum'
a.def(:foo) do
  puts self
end

a.foo # works
'blah'.foo # raises error
