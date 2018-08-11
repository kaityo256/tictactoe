require "optparse"
require "./tictactoe.rb"

opts = {showprob: false, savehash: false}
op = OptionParser.new

op.on("-d") do |v|
  opts[:savehash] = v
end

op.on("-o FILENAME") do |v|
  opts[:filename] = v
end

op.on("-s", "--show", "show probability (default: #{opts[:showprob]})") do |v|
  opts[:showprob] = v
end

op.parse!(ARGV)
str = ARGV[0]

if opts[:savehash]
  TTT.savehash
  exit
end

if str.nil?
  puts "Please specify state (ex. 020100111)"
  exit
end

if str !~ /^[012]+$/ || str.length != 9
  puts "Invalid state"
  exit
end

state = str.split(//).map(&:to_i)
TTT.show(state)

if opts[:showprob]
  prob = TTT.search(state)
  TTT.show_prob(prob)
  unless opts[:filename].nil?
    TTT.savetopng_withprob(state, prob, opts[:filename])
  end
else
  TTT.savetopng(state, opts[:filename]) unless opts[:filename].nil?
end
