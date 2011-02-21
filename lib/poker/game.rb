require File.expand_path("../../poker", __FILE__)

class Game
  attr_reader :big_blind, :small_blind, :players, :next_position, :to_call
  attr_accessor :pot

  state_machine :initial => :waiting do

    after_transition :waiting => :deal, :do => :deal_players
    after_transition :deal => :flop, :do => :deal_flop
    after_transition :flop => :turn, :do => :deal_turn
    after_transition :turn => :river, :do => :deal_river
    after_transition :river => :showdown, :do => :resolve_hands
    after_transition :showdown => :deal, :do => :move_button

    event :start do
      transition :waiting => :deal
    end

    event :deal do
      transition :deal  => :flop, :if => lambda { |g| g.called? }
      transition :flop  => :turn, :if => lambda { |g| g.called? }
      transition :turn  => :river, :if => lambda { |g| g.called? }
      transition :river => :showdown, :if => lambda { |g| g.called? }
      transition :showdown => :deal, :if => lambda { |g| g.called? }
    end
  end

  def initialize(small_blind, big_blind)
    @pot           = 0
    @players       = []
    @deck          = Deck.new
    @table         = Table.new(self)
    @to_call       = big_blind
    @big_blind     = big_blind
    @small_blind   = small_blind
    @next_position = 0
    @offset        = 0
    @call_check    = 0
    @folded        = 0
    super
  end

  def deal_players
    @deck.shuffle
    @next_position = 1 # deal left of button

    (@players.size*2).times do
      next_player.deal(@deck.deal)
      increment_position!
    end

    @next_position = 0
  end

  def deal_flop
    @deck.deal # burn a card
    3.times { @table.deal(@deck.deal) }
    @table.check
  end

  def deal_turn
    @deck.deal # burn a card
    @table.deal(@deck.deal)
  end

  def deal_river
    @deck.deal # burn a card
    @table.deal(@deck.deal)
  end

  def resolve_hands
  end

  def table_cards
    @table.cards
  end

  def move_button
    @offset = (@offset + 1) % @players.size
  end

  def table_state
    @table.state.to_sym
  end

  def raise(player, amount)
    if @table.can_raise? == false
      error("cannot raise, table is in #{@table.state}")
      return false
    end

    if amount <= @to_call
      error("raise must be > call")
      return false
    end

    @pot += amount
    @to_call = amount

    @table.raise

    @call_check = 1

    debug(player, "raised: #{amount}, pot: #{@pot}, state: #{@state}")

    increment_position!
  end

  def call(player, amount)
    if @table.can_call? == false
      error("cannot call, table is in #{@table.state}")
      return false
    end

    if amount == 0
      debug(player, "tried to call #{amount}, ignoring")
      return false
    end

    @call_check += 1

    @pot += amount

    debug(player, "called: #{amount}, pot: #{@pot}, state: #{@state}")

    @table.call

    increment_position!

    return true
  end

  def post_blind(player, amount)
    if @table.can_post_blind? == false
      error("cannot post blind, table is in #{@table.state}")
      return false
    end

    @pot += amount

    if @pot == @big_blind + @small_blind
      @to_call = @big_blind
      @call_check += 1
      3.times { increment_position! }
      @table.post_blind
    end

    debug(player, "posted blind: #{amount}, pot: #{@pot}, state: #{@state}")
  end

  def fold(player)
    debug(player, "folded, pot: #{@pot}, state: #{@state}")
    @folded += 1
    increment_position!
  end

  def check(player)
    if @table.can_check? == false
      error("cannot check, table is in #{@table.state}")
      return false
    end

    debug(player, "checked, pot: #{@pot}, state: #{@state}")
    @call_check += 1

    increment_position!

    @table.check
    return true
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
    return @players[((@next_position - 1 - @offset) % @players.size)]
  end

  def dealer_player
    return @players[0 + @offset]
  end

  def big_blind_player
    return @players[2 + @offset]
  end

  def small_blind_player
    return @players[1 + @offset]
  end

  def increment_position!
    @next_position = (@next_position + 1 + @offset) % @players.size
    @next_position
  end

  def called?
    if (@call_check == @players.size - @folded)
      @table.called
      @call_check = 0
      return true
    else
      return false
    end
  end
end
