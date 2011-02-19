require 'deck'
require 'table'

class Game
  attr_reader :big_blind, :small_blind, :players, :next_position, :to_call
  attr_accessor :state, :pot

  @@state = [
    :post_blind,
    :call,
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
    @call_check    = 0
    @folded        = 0
  end

  def raise(player, amount)
    if amount <= @to_call
      error("raise must be > call")
      return false
    end

    @pot += amount
    @to_call = amount
    @state = :raise

    @call_check = 1

    debug(player, "raised: #{amount}, pot: #{@pot}, state: #{@state}")

    increment_position!
  end

  def call(player, amount)
    if amount == 0
      debug(player, "tried to call #{amount}, ignoring")
      return
    end

    @call_check += 1

    @pot += amount

    debug(player, "called: #{amount}, pot: #{@pot}, state: #{@state}")

    increment_position!
  end

  def post_blind(player, amount)
    @pot += amount

    if @pot == @big_blind + @small_blind
      @state = :call
      @to_call = @big_blind
      @call_check += 1
      3.times { increment_position! }
    end

    debug(player, "posted blind: #{amount}, pot: #{@pot}, state: #{@state}")
  end

  def fold(player)
    debug(player, "folded, pot: #{@pot}, state: #{@state}")
    @folded += 1
    increment_position!
  end

  def check(player)
    debug(player, "checked, pot: #{@pot}, state: #{@state}")
    @call_check += 1
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
    return @players[next_position]
  end

  def previous_player
    return @players[((@next_position - 1) % @players.size)]
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

  def increment_position!
    @next_position = (@next_position + 1) % @players.size
    @next_position
  end

  def called?
    # fast path, if we get to a player who has to call with zero dollars,
    # otherwise we have to make sure everyone has called
    if (@call_check == @players.size - @folded)
      return true
    else
      return false
    end
  end

  def current_deal
    @table.state
  end

  def deal
    unless called?
      error("cannot deal until current deal is called")
      return false
    end

    @table.next_deal
    @called = 0

    return @table.state
  end
end
