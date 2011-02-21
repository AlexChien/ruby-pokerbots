require File.expand_path("../spec_helper", __FILE__)

describe Player do
  include Wrong

  before(:each) do
    @game = Game.new(5, 10)

    6.times do
      player = Player.new(@game, 100)
      player.stubs(:error)
      @game.stubs(:debug)
      @game.add_player(player)
    end
  end

  describe "when the game is in post_blind state" do

    it "the dealer should pay nothing" do
      assert { @game.dealer_player.available_actions == [] }
      assert { @game.dealer_player.post_blind == false }
    end

    it "the player to the left of the blind should pay nothing" do
      assert { @game.players[3].available_actions == [] }
      assert { @game.players[3].post_blind == false }
    end

    it "the small blind should pay the small blind" do
      assert { @game.small_blind_player.available_actions == [:post_blind] }
      assert { @game.small_blind_player.post_blind }
      assert { @game.small_blind_player.chips == (100-@game.small_blind) }
    end

    it "the big blind should pay the big blind" do
      assert { @game.big_blind_player.available_actions == [:post_blind] }
      assert { @game.big_blind_player.post_blind }
      assert { @game.big_blind_player.chips == (100 - @game.big_blind) }
    end
  end

  # describe "when the blinds have been posted and the game is in call state" do
  #   before do
  #     SpecUtils::post_blinds(@game)
  #   end
  #
  #   it "the player to the left of the big blind should be next to play" do
  #     assert { @game.next_player == @game.players[3] }
  #   end
  #
  #   it "the player should be able to call, raise, fold or all_in" do
  #     assert { @game.next_player.available_actions == [:call, :raise, :fold, :all_in] }
  #   end
  # end
  #
  # describe "when the game is in the raise state" do
  #   before do
  #     SpecUtils::raise_state(@game, 20)
  #   end
  #
  #   it "the player should be able to call, raise, fold or all_in" do
  #     assert { @game.next_player.available_actions == [:call, :raise, :fold, :all_in] }
  #   end
  #
  #   it "the player must call the correct amount and pay for it" do
  #     assert { @game.next_player.to_call == 30 }
  #   end
  #
  #   describe "when the player calls" do
  #     it "should pay the call amount" do
  #       to_call = @game.to_call
  #       @game.next_player.to_call
  #       assert { @game.previous_player.chips == (100-to_call)}
  #     end
  #   end
  #
  #   describe "when the player folds" do
  #     it "should pay nothing" do
  #       @game.next_player.fold
  #       assert { @game.previous_player.chips == 100 }
  #     end
  #   end
  # end
  #
  # describe "when all players call to the small blind" do
  #   before do
  #     SpecUtils::calls_to_small_blind(@game, @game.players.size)
  #   end
  #
  #   it "next player should be the small blind" do
  #     assert { @game.next_player == @game.small_blind_player }
  #   end
  #
  #   it "should only have to pay the small blind to call" do
  #     assert { @game.next_player.to_call == @game.small_blind }
  #   end
  #
  #   it "should not be able to check instead of call" do
  #     assert { @game.next_player.available_actions.include?(:check) == false }
  #   end
  #
  #   it "should pay the call amount" do
  #     to_call = @game.to_call
  #     @game.next_player.call
  #     assert { @game.previous_player.chips == (100-(@game.small_blind*2))}
  #   end
  # end
  #
  # describe "when all players call to the big blind" do
  #   before do
  #     SpecUtils::calls_to_big_blind(@game, @game.players.size)
  #   end
  #
  #   it "next player should be the big blind" do
  #     assert { @game.next_player == @game.big_blind_player }
  #   end
  #
  #   it "should be able to check, raise or go all in" do
  #     assert { @game.next_player.available_actions == [:raise, :all_in, :check]}
  #   end
  #
  #   it "should only have to check to call" do
  #     assert { @game.next_player.to_call == 0 }
  #   end
  #
  #   it "should pay nothing when checking" do
  #     to_call = @game.to_call
  #     @game.next_player.check
  #     assert { @game.previous_player.chips == (100-@game.big_blind)}
  #   end
  # end
end
