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

# TicTacToe WinCheck
module TTTWinCheck
  class << self
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
  end
end

# TicTacToe Module
module TTT
  TIC = 1
  TAC = 2
  @qhash = {}

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

    def win(arr, player)
      TTTWinCheck.win(arr, player)
    end

    def arr2index(arr, index)
      idx = 0
      arr.each_with_index do |v, i|
        idx += v * (3 ** i)
      end
      index + idx * 9
    end

    def search_tic(index, arr)
      b = arr.deep_dup
      b[index] = TTT::TIC
      idx = arr2index(b, index)
      return @qhash[idx] if @qhash.key?(idx)
      v = 0
      if win(b, TTT::TIC)
        v = 1
      elsif b.count(0).zero?
        v = 0
      else
        t = b.find_all_index(&:zero?)
        v = t.map { |i| search_tac(i, b) }.mean
      end
      @qhash[idx] = v
      v
    end

    def search_tac(index, arr)
      b = arr.deep_dup
      b[index] = TTT::TAC
      idx = arr2index(b, index)
      return @qhash[idx] if @qhash.key?(idx)
      v = -1
      unless win(b, TTT::TAC)
        t = b.find_all_index(&:zero?)
        r = t.map { |i| search_tic(i, b) }
        v = r.mean
      end
      @qhash[idx] = v
      v
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
    end

    def savetopng_withprob(state, prob, filename)
      TTTImage.save_state_withprob(filename, state, prob)
    end
  end
end
