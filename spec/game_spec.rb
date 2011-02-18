require File.expand_path("../spec_helper", __FILE__)

describe Player do
  before(:each) do
    @game = Game.new(5, 10)

    4.times do
      player = Player.new(@game, 100)
      @game.add_player(player)
    end

  end

  # describe "when the game is in post_blind state and the players have posted the blinds" do
  #   it "should go to the bet state" do
  #     @game.state.must_equal :post_blind
  #     @game.big_blind_player.post_blind
  #     @game.small_blind_player.post_blind
  #     @game.state.must_equal :bet
  #     @game.pot.must_equal(@game.big_blind + @game.small_blind)
  #   end
  # end
  #
  # describe "when the game is in bet state and a player raise" do
  #   it "should go to the raise state" do
  #     @game.big_blind_player.post_blind
  #     @game.small_blind_player.post_blind
  #     @game.state.must_equal :bet
  #     @game.next_player.raise(15)
  #     @game.state.must_equal :raise
  #     @game.pot.must_equal(@game.big_blind+@game.small_blind+15)
  #   end
  # end
  #
  # describe "when the game is in raise state and a player calls" do
  #   it "should stay in the raise state" do
  #     @game.big_blind_player.post_blind
  #     @game.small_blind_player.post_blind
  #     @game.next_player.raise(20)
  #     @game.state.must_equal :raise
  #     @game.next_player.call
  #     @game.state.must_equal :raise
  #     @game.pot.must_equal(15+20+20)
  #   end
  # end
  #
  # describe "when the game is in raise state and a player raises" do
  #   it "should stay in raise state but to_call should be bigger" do
  #     @game.big_blind_player.post_blind
  #     @game.small_blind_player.post_blind
  #     @game.next_player.raise(20)
  #     @game.state.must_equal :raise
  #     @game.next_player.raise(20)
  #     @game.state.must_equal :raise
  #     @game.pot.must_equal(15+20+40)
  #     @game.to_call.must_equal(40)
  #   end
  # end

  describe "when the game goes around the table completely" do
    it "should mark everyone as called" do
      @game.small_blind_player.post_blind
      @game.big_blind_player.post_blind

      @game.next_player.raise(20) # player 2
      @game.state.must_equal :raise
      @game.next_player.raise(20) # player 3
      @game.state.must_equal :raise

      @game.next_player.call
      @game.next_player.call
      @game.next_player.raise(20)

      @game.next_player.call

      @game.called?.must_equal true
    end
  end

end