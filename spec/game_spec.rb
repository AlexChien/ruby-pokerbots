require File.expand_path("../spec_helper", __FILE__)

describe Game do
  include Wrong

  before(:each) do
    @game = Game.new(5, 10)

    6.times do
      player = Player.new(@game, 100)
      @game.add_player(player)
    end
  end

  describe "when the game is in post_blind state and the players have posted the blinds" do
    it "should go to the call state" do
      SpecUtils::post_blinds(@game)
      assert { @game.table_state == :call }
      assert { @game.pot == (@game.big_blind + @game.small_blind) }
    end
  end

  describe "when the game is in call state" do
    before do
      SpecUtils::post_blinds(@game)
    end

    describe "and a player calls" do
      before do
        @game.next_player.call
      end

      it "should stay in the call state" do
        assert { @game.table_state == :call }
      end

      it "the games pot should be equal to the big blind + small blind + players blind" do
        assert { @game.pot == (@game.big_blind+@game.small_blind+@game.big_blind) }
      end

      it "the games to call should still be equal to the big blind" do
        assert { @game.to_call == @game.big_blind }
      end
    end

    describe "and a player folds" do
      before do
        @before_pot = @game.pot
        @before_call = @game.to_call
        @game.next_player.fold
      end

      it "should stay in the call state" do
        assert { @game.table_state == :call }
      end

      it "the games pot be unchanged" do
        assert { @game.pot == @before_pot }
      end

      it "the games to call be unchanged" do
        assert { @game.to_call == @before_call }
      end
    end

    describe "and a player raises" do
      before do
        @game.next_player.raise(15)
      end

      it "should go to the raise state" do
        assert { @game.table_state == :raise }
      end

      it "the games pot should be equal to the big blind + small blind + players blind + his raise" do
        assert { @game.pot == (@game.big_blind+@game.small_blind+@game.big_blind+15) }
      end

      it "the games to call should be equal to the big blind plus the raise" do
        assert { @game.to_call == @game.big_blind + 15 }
      end
    end
  end

  describe "when the game is in the raise state" do
    before do
      SpecUtils::raise_state(@game, 15)
    end

    describe "and a player calls" do
      before do
        @previous_to_call = @game.to_call
        @game.next_player.call
      end

      it "should stay in the raise state" do
        assert { @game.table_state == :raise }
      end

      it "the games pot should equal all the blinds + the initial raise + our call" do
        assert { @game.pot == (@game.big_blind+@game.small_blind+@game.big_blind+15+@game.to_call) }
      end

      it "the games to call should stay the same" do
        assert { @game.to_call == @previous_to_call }
      end
    end

    describe "and a player folds" do
      before do
        @before_pot = @game.pot
        @before_call = @game.to_call
        @game.next_player.fold
      end

      it "should stay in the raise state" do
        assert { @game.table_state == :raise }
      end

      it "the games pot be unchanged" do
        assert { @game.pot == @before_pot }
      end

      it "the games to call be unchanged" do
        assert { @game.to_call == @before_call }
      end
    end

    describe "and a player re-raises" do
      before do
        @game.next_player.raise(20)
        @to_call = @game.big_blind + 15 + 20 # blind + initial raise + reraise
      end

      it "should stay in the raise state" do
        assert { @game.table_state == :raise }
      end

      it "the games pot should equal all the blinds + the initial raise + the reraise" do

        assert { @game.pot == (@game.big_blind+@game.small_blind+@game.big_blind+15+@to_call) }
      end

      it "the games to call should now increase to the sum of both raises and the big blind" do
        assert { @game.to_call == @to_call }
      end
    end
  end

  describe "when everyone has folded or called (simple case)" do
    before do
      SpecUtils::everyone_calls(@game, @game.players.size)
    end

    it "each player who called should have contributed the same amount to the pot" do
      ret = true

      @game.players.each do |player|
        next if player.action == :fold
        if player.total_in_pot != @game.to_call
          ret = false
        end
      end

      assert { ret == true }
    end

    it "the current deal should be resolved" do
      assert { @game.called? == true }
    end

    describe "and the game begins the next deal" do
      before do
        @game.deal
      end

      it "should go to the flop deal" do
        assert { @game.state == 'flop' }
      end
    end
  end

  describe "when everyone has folded or called (complex case)" do
    before do
      SpecUtils::everyone_calls_complex(@game, @game.players.size)
    end

    it "each player who called should have contributed the same amount to the pot" do
      ret = true

      @game.players.each do |player|
        next if player.action == :fold
        if player.total_in_pot != @game.to_call
          ret = false
        end
      end

      assert { ret == true }
    end

    it "the current deal should be resolved" do
      assert { @game.called? == true }
    end

    describe "and the game begins the next deal" do
      before do
        @game.deal
      end

      it "should go to the flop deal" do
        assert { @game.state == 'flop' }
      end
    end
 end
end