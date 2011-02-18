require File.expand_path("../spec_helper", __FILE__)

describe Player do
  before(:each) do
    @game = Game.new(nil, 5, 10)

    4.times do
      player = Player.new(@game, 100)
      @game.add_player(player)
    end
  end

  describe "when the game is in post_blind state" do
    it "the dealer should pay nothing" do
      @game.players[0].available_actions.must_equal []
      @game.players[0].post_blind.must_equal false
    end

    it "the player to the left of the blind should pay nothing" do
      @game.players[3].available_actions.must_equal []
      @game.players[3].post_blind.must_equal false
    end

    it "the small blind should pay the small blind" do
      @game.players[1].available_actions.must_equal [:post_blind]
      @game.players[1].post_blind
      @game.pot.must_equal @game.small_blind
      @game.players[1].chips.must_equal(100 - @game.small_blind)
    end

    it "the big blind should pay the big blind" do
      @game.players[2].available_actions.must_equal [:post_blind]
      @game.players[2].post_blind
      @game.pot.must_equal @game.big_blind + @game.small_blind
      @game.players[2].chips.must_equal(100 - @game.big_blind)
    end
  end

  describe "when the game is in the bet state" do
    it "the player to the left should be next to play" do
      (@game.next_player == @game.players[3]).must_equal true
    end

    it "the player should be able to bet, raise, fold or all_in" do
      @game.next_player.available_actions.must_equal [:call, :bet, :raise, :fold, :all_in]
    end
  end

  describe "when the game is in bet state and the next player bets" do
    it "should increase the game's pot size" do
      @game.next_player.bet(15).must_equal true
      @game.pot.must_equal 30
      @game.state.must_equal :bet
    end
  end

  describe "when the game is in the bet state and the next player calls" do
    it "should increase the game's pot size by to_call" do
      player = @game.next_player
      to_call = player.to_call
      chips = player.chips
      player.call.must_equal true
      @game.pot.must_equal 45
      @game.state.must_equal :bet
      player.chips.must_equal chips-to_call
    end
  end

  describe "when the game is in bet state and the next player folds" do
    it "should increase the game's pot by zero and take cost the player nothing" do
      player = @game.next_player
      chips = player.chips
      player.fold.must_equal true
      @game.pot.must_equal 45
      player.chips.must_equal chips
    end
  end

  describe "when the game is in bet state and the next player raises" do
    it "should increase the game's pot, the to_call and take cost the player the raise" do
      player = @game.next_player
      chips = player.chips
      player.raise(15).must_equal false
      player.raise(20).must_equal true
      @game.pot.must_equal 45+20
      @game.state.must_equal :raise
      player.chips.must_equal chips-20
    end
  end

end
