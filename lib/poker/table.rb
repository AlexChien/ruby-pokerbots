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
      transition :called => :check
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

  attr_reader :cards

  def initialize(game)
    @game = game
    @cards = []
    super
  end

  def deal(card)
    @cards << card
  end
end
