require "optparse"
require "./tttuct.rb"

op = OptionParser.new

opts = {i: 1000}

op.on("-o FILENAME") do |v|
  opts[:filename] = v
end

op.on("-i NUM") do |v|
  opts[:i] = v.to_i
end

op.parse!(ARGV)

exit if ARGV.size.zero?

a = ARGV[0].to_arr

srand(1)

n = opts[:i]
n.times do
  TTTUCT.search(a)
end
s = TTTUCT.get_state(a)

s.show

s.savetopng(opts[:filename]) if opts.key? :filename
