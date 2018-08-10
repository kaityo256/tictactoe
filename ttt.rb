require "optparse"
require "./image.rb"

# Arrayにメソッドを追加
class Array
  def deep_dup
    Marshal.load(Marshal.dump(self))
  end

  def sum
    reduce(:+)
  end

  def mean
    sum.to_f / size
  end

  def find_all_index
    a = []
    each_with_index do |v, i|
      a << i if yield v
    end
    a
  end
end

# TicTacToe Module
module TTT
  TIC = 1
  TAC = 2

  class << self
    def show(state)
      puts "Input state"
      puts
      b = [" ", "o", "x"]
      arr = state.map { |v| b[v] }
      puts arr[0..2].join("|")
      puts arr[3..5].join("|")
      puts arr[6..8].join("|")
      puts
    end

    def show_prob(prob)
      a = prob.map { |v| format("%+.2f", v) }
      puts "Probability"
      puts
      puts a[0..2].join("|")
      puts a[3..5].join("|")
      puts a[6..8].join("|")
      puts
    end

    def a2b(arr)
      tic = 0
      tac = 0
      9.times do |i|
        tic += (1 << i) if arr[i] == 1
        tac += (1 << i) if arr[i] == 2
      end
      [tic, tac]
    end

    def win_row(arr, player)
      t = a2b(arr)[player - 1]
      k = Integer("0b000000111")
      return true if (t & k) == k
      return true if ((t >> 3) & k) == k
      return true if ((t >> 6) & k) == k
      false
    end

    def win_column(arr, player)
      t = a2b(arr)[player - 1]
      k = Integer("0b001001001")
      return true if (t & k) == k
      return true if ((t >> 1) & k) == k
      return true if ((t >> 2) & k) == k
      false
    end

    def win_diagonal(arr, player)
      t = a2b(arr)[player - 1]
      k1 = Integer("0b100010001")
      k2 = Integer("0b001010100")
      return true if (t & k1) == k1
      return true if (t & k2) == k2
    end

    def win(arr, player)
      return true if win_row(arr, player)
      return true if win_column(arr, player)
      return true if win_diagonal(arr, player)
      false
    end

    def search_tic(index, arr)
      b = arr.deep_dup
      b[index] = TTT::TIC
      return 1 if win(b, TTT::TIC)   # Tic 勝利
      return 0 if b.count(0).zero?   # 引き分け
      t = b.find_all_index(&:zero?)
      r = t.map { |i| search_tac(i, b) }
      r.mean
    end

    def search_tac(index, arr)
      b = arr.deep_dup
      b[index] = TTT::TAC
      return -1 if win(b, TTT::TAC)
      t = b.find_all_index(&:zero?)
      r = t.map { |i| search_tic(i, b) }
      r.mean
    end

    def search(arr)
      prob = Array.new(9) { 0 }
      t = arr.find_all_index(&:zero?)
      if t.size.odd?
        t.map { |i| prob[i] = search_tic(i, arr) }
      else
        t.map { |i| prob[i] = search_tac(i, arr) }
      end
      prob
    end

    def savetopng(state, filename)
      TTTImage.save_state(filename, state)
      puts "Save to #{filename}"
    end

    def savetopng_withprob(state, prob, filename)
      TTTImage.save_state_withprob(filename, state, prob)
      puts "Save to #{filename}"
    end
  end
end

opts = {showprob: false}
op = OptionParser.new

op.on("-o FILENAME") do |v|
  opts[:filename] = v
end

op.on("-s", "--show", "show probability (default: #{opts[:showprob]})") do |v|
  opts[:showprob] = v
end

op.parse!(ARGV)
str = ARGV[0]

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
