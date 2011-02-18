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

  def initialize(small_blind, big_blind)
    @state         = :post_blind
    @pot           = 0
    @players       = []
    @deck          = Deck.new
    @table         = Table.new
    @to_call       = big_blind
    @big_blind     = big_blind
    @small_blind   = small_blind
    @next_position = 0
    @turn_offset   = 0
  end

  def bet(player, amount)
    @pot += amount
    @to_call = amount
    @state = :bet

    debug(player, "raised: #{amount}, pot: #{@pot}, state: #{@state}")

    increment_position
  end

  def raise(player, amount)
    if amount <= @to_call
      error("raise must be > call")
      return false
    end

    @pot += amount
    @to_call = amount
    @state = :raise

    debug(player, "raised: #{amount}, pot: #{@pot}, state: #{@state}")

    increment_position
  end

  def call(player, amount)
    @pot += amount
    @state = :raise

    debug(player, "called: #{amount}, pot: #{@pot}, state: #{@state}")

    increment_position
  end

  def post_blind(player, amount)
    @pot += amount

    if @pot == @big_blind + @small_blind
      @state = :bet
      3.times { increment_position }
    end

    debug(player, "posted blind: #{amount}, pot: #{@pot}, state: #{@state}")
  end

  def fold(player)
    debug(player, "folded, pot: #{@pot}, state: #{@state}")

    increment_position
  end

  def check(player)
    debug(player, "checked, pot: #{@pot}, state: #{@state}")
    @state = :check
  end

  def add_player(player)
    player.position = @players.size
    @players << player
  end

  def error(msg)
    puts "ERROR (Game): #{msg}"
  end

  def debug(player, msg)
    puts "(Player Dealer+#{player.position}) #{msg}"
  end

  def next_player
    player = @players[@next_position]
    return player
  end

  def dealer_player
    return @players[0]
  end

  def big_blind_player
    return @players[2]
  end

  def small_blind_player
    return @players[1]
  end

  def increment_position
    @next_position = (@next_position + 1) % @players.size
    @next_position
  end

  def called?
    @players.each do |player|
      p "#{player.position} => #{player.total_in_pot}"
      if player.total_in_pot != @to_call
        # return false
      end
    end

    @state = :call

    return true
  end
end