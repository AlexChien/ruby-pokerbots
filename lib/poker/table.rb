require File.expand_path("../../poker", __FILE__)

class Table
  state_machine :initial => :open do

    event :post_blind do
      transition :open => :call
    end

    event :call do
      transition :call => :call
      transition :raise => :raise
    end

    event :check do
      transition :check => :check
    end

    event :raise do
      transition :call => :raise
      transition :raise => :raise
    end

    event :called do
      transition :raise => :called
      transition :call => :called
    end
  end

  def initialize(game)
    @game = game
    @flop_cards = []
    @turn_card  = nil
    @river_card = nil
    super
  end
end
