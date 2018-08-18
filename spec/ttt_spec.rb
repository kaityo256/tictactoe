require "rspec"
require "./tictactoe.rb"

describe :a2b do
  example "テスト" do
    expect(TTTWinCheck.a2b([0, 0, 0, 0, 0, 0, 0, 0, 0])).to eq [0, 0]
    expect(TTTWinCheck.a2b([1, 0, 0, 0, 0, 0, 0, 0, 0])).to eq [1, 0]
    expect(TTTWinCheck.a2b([0, 1, 0, 0, 0, 0, 0, 0, 0])).to eq [2, 0]
    expect(TTTWinCheck.a2b([2, 0, 0, 0, 0, 0, 0, 0, 0])).to eq [0, 1]
    expect(TTTWinCheck.a2b([1, 2, 0, 0, 0, 0, 0, 0, 0])).to eq [1, 2]
  end
end

describe :win do
  example "row" do
    expect(TTT.win([1, 1, 1, 0, 0, 0, 0, 0, 0], TTT::TIC)).to eq true
    expect(TTT.win([1, 0, 1, 0, 0, 0, 0, 0, 0], TTT::TIC)).to eq false
    expect(TTT.win([0, 0, 0, 1, 1, 1, 0, 0, 0], TTT::TIC)).to eq true
    expect(TTT.win([0, 0, 0, 0, 0, 0, 1, 1, 1], TTT::TIC)).to eq true
    expect(TTT.win([2, 2, 2, 0, 0, 0, 0, 0, 0], TTT::TAC)).to eq true
  end
  example "column" do
    expect(TTT.win([1, 0, 0, 1, 0, 0, 1, 0, 0], TTT::TIC)).to eq true
    expect(TTT.win([0, 1, 0, 0, 1, 0, 0, 1, 0], TTT::TIC)).to eq true
    expect(TTT.win([0, 0, 1, 0, 0, 1, 0, 0, 1], TTT::TIC)).to eq true
  end
  example "diagonal" do
    expect(TTT.win([1, 2, 2, 0, 1, 0, 2, 0, 1], TTT::TIC)).to eq true
    expect(TTT.win([1, 2, 2, 0, 1, 0, 2, 0, 1], TTT::TAC)).to eq false
    expect(TTT.win([1, 2, 2, 0, 2, 0, 2, 0, 1], TTT::TAC)).to eq true
  end
end

describe :search_tic do
  example "win" do
    expect(TTT.search_tic(2, [1, 1, 0, 2, 2, 0, 0, 0, 0])).to eq 1
    expect(TTT.search_tic(4, [1, 2, 0, 0, 0, 2, 0, 0, 1])).to eq 1
    expect(TTT.search_tic(1, [1, 0, 1, 1, 2, 2, 2, 1, 2])).to eq 1
    expect(TTT.search_tic(6, [1, 2, 1, 2, 1, 2, 0, 0, 0])).to eq 1
    expect(TTT.search_tic(7, [1, 2, 1, 2, 1, 2, 0, 0, 0])).to eq 1
    expect(TTT.search_tic(8, [1, 2, 1, 2, 1, 2, 0, 0, 0])).to eq 1
  end
  example "lose" do
    expect(TTT.search_tac(7, [1, 2, 1, 1, 2, 0, 0, 0, 0])).to eq(-1)
    expect(TTT.search_tac(4, [1, 1, 2, 0, 0, 1, 2, 0, 0])).to eq(-1)
  end

  example "draw" do
    expect(TTT.search_tic(0, [0, 1, 2, 2, 2, 1, 1, 2, 1])).to eq 0
  end

  example "possiblility" do
    expect(TTT.search_tic(1, [1, 0, 2, 2, 1, 1, 0, 0, 2])).to eq 0.5
  end
end
