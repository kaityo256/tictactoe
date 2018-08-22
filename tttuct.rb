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

  # 期待値と回数配列からUCBの配列を作成する
  def ucb_array(ave, num)
    total = num.sum.to_f
    r = Array.new(num.size) do |j|
      u = Math.sqrt(2.0 * Math.log(total) / num[j])
      ave[j] + u
    end
    r
  end

  # UCBに従って場所を選ぶ
  def ucb_select(player)
    mu = @award.div(@num)
    mu.map!(&:-@) if player == TTT::TAC
    r = ucb_array(mu, @num)
    r.max_index
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

  def savetopng(filename)
    mu = @award.div(@num)
    prob = Array.new(9) { 0 }
    @pos.size.times do |i|
      prob[@pos[i]] = mu[i]
    end
    TTTImage.save_state_withprob(filename, @arr, prob)
  end
end

# TicTacToe with UCT
module TTTUCT
  @shash = {}
  class << self
    def showhash
      p @shash
    end

    def get_state(arr)
      key = arr.join("")
      @shash[key] = TState.new(arr) unless @shash.key?(key)
      @shash[key]
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

    def search(arr)
      if arr.count(0).odd?
        search_tic(arr)
      else
        search_tac(arr)
      end
    end
  end
end
