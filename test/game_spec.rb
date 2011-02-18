$: << File.join(File.dirname(__FILE__), "..")

require 'rubygems'
require 'rspec'

require 'game'
require 'player'

describe Player do
  before(:each) do
    allow_message_expectations_on_nil

    @game = Game.new(nil, 5, 10)

    4.times do
      player = Player.new(@game, 100)
      player.stub!(:error)
      @game.add_player(player)
    end
  end

  describe "when the game is in post_blind state and the players have posted the blinds" do
    it "should go to the bet state" do
      @game.players[1].post_blind
      @game.players[2].post_blind
      @game.state.should == :bet
    end
  end
end