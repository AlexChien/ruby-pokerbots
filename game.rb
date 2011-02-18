require 'deck'
require 'table'

class Game
  attr_reader :big_blind, :small_blind, :players, :next_position, :to_call
  attr_accessor :state, :pot, :last_bet

  @@state = [
    :post_blind,
    :bet,
    :raise,
    :check
  ]

  def initialize(deck, small_blind, big_blind)
    @state      = :post_blind
    @pot        = 0
    @players    = []
    @deck       = deck
    @table      = Table.new
    @to_call    = big_blind
    @big_blind  = big_blind
    @small_blind = small_blind
    @next_position = 0
  end

  def bet(amount)
    @pot += amount
    @to_call = amount
    @state = :bet
    increment_position
  end

  def raise(amount)
    @pot += amount
    @to_call = amount
    @state = :raise
    increment_position
  end

  def post_blind(amount)
    @pot += amount
    if @pot == @big_blind + @small_blind
      @state = :bet
      3.times { increment_position }
    end
  end

  def fold
    increment_position
  end

  def check
    @state = :check
  end

  def add_player(player)
    player.position = @players.size
    @players << player
  end

  def error(msg)
    puts "ERROR (Game): #{msg}"
  end

  def next_player
    player = @players[@next_position]
    return player
  end

  def increment_position
    @next_position = (@next_position + 1) % @players.size
  end
end