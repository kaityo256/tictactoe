require "./tictactoe.rb"

# 状態を記憶する
class TState
  def initialize(arr)
    # 現在の状態
    @arr = arr
    # おける場所
    @pos = arr.find_all_index(&:zero?)
    # その場所に何度置いたか
    @num = Array.new(@pos.size) { 0 }
    # これまでの総報酬
    @award = Array.new(@pos.size) { 0.0 }
  end

  # UCBに従って場所を選ぶ
  def ucb_select(player)
    mu = @award.div(@num)
    mu.map!(&:-@) if player == TTT::TAC
    total = @num.inject(:+).to_f
    r = Array.new(@num.size) do |j|
      u = Math.sqrt(2.0 * Math.log(total) / @num[j])
      mu[j] + u
    end
    r.index(r.max)
  end

  def select(player)
    t = @num.find_all_index(&:zero?)
    if t.size.zero?
      # すべて選んだことがあれば、UCBが最大のものを選ぶ
      @pos[ucb_select(player)]
    else
      # もしまだ選んでいない場所があれば、その場所をランダムに選ぶ
      @pos[t.sample]
    end
  end

  def add(index, value)
    i = @pos.index(index)
    @num[i] += 1
    @award[i] += value
  end

  def show
    TTT.show(@arr)
    mu = @award.div(@num)
    a = Array.new(9) { 0 }
    @pos.size.times do |i|
      a[@pos[i]] = mu[i]
    end
    TTT.show_prob(a)
  end
end

# TicTacToe with UCT
module TTTUCT
  @shash = {}
  class << self
    def showhash
      p @shash
    end

    # TTT.arr2indexとは意味が異なるので注意
    def arr2index(arr)
      index = 0
      arr.each_with_index do |v, i|
        index += v * (3 ** i)
      end
      index
    end

    def get_state(arr)
      index = arr2index(arr)
      @shash[index] = TState.new(arr) unless @shash.key?(index)
      @shash[index]
    end

    # TICの手番
    def search_tic(arr)
      return -1 if TTTWinCheck.win(arr, TTT::TAC)
      s = get_state(arr)
      i = s.select(TTT::TIC)
      b = arr.deep_dup
      b[i] = TTT::TIC
      v = search_tac(b)
      s.add(i, v)
      v
    end

    # TACの手番
    def search_tac(arr)
      return 1 if TTTWinCheck.win(arr, TTT::TIC) # TIC勝利
      return 0 if arr.count(0).zero? # 引き分け
      s = get_state(arr)
      i = s.select(TTT::TAC)
      b = arr.deep_dup
      b[i] = TTT::TAC
      v = search_tic(b)
      s.add(i, v)
      v
    end
  end
end

a = "020010000".split(//).map(&:to_i)

srand(1)

10000.times do
  TTTUCT.search_tic(a)
end
TTTUCT.get_state(a).show
