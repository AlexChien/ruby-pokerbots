require File.expand_path("../../poker", __FILE__)

class Player
  attr_accessor :position, :chips, :action
  attr_reader :total_in_pot, :cards

  # game state => player actions
  @@actions = {
    :open  => [:post_blind],
    :call       => [:call, :raise, :fold, :all_in],
    :check      => [:raise, :check, :all_in],
    :raise      => [:call, :raise, :fold, :all_in]
  }

  def initialize(game, chips)
    @game     = game
    @chips    = chips
    @state    = :call
    @actions  = []
    @position = nil
    @last_bet = 0
    @total_in_pot = 0
    @cards = []
  end

  def deal(card)
    @cards << card
  end

  def error(msg)
    puts "ERROR (Player #{@position}): #{msg}"
  end

  def post_blind
    if not @@actions[@game.table_state].include?(:post_blind)
      error("cannot bet when game.table_state == #{@game.table_state}")
      return false
    end

    if @position != 1 and @position != 2
      error("not playing in the blinds")
      return false
    end

    if @position == 2
      amount = @game.big_blind
    end

    if @position == 1
      amount = @game.small_blind
    end

    if amount > @chips
      error("cannot post blind #{amount} > #{@chips}")
      return false
    end

    @chips -= amount
    @game.post_blind(self, amount)
    @action = :post_blind
    @total_in_pot += amount

    return true
  end

  def to_call
    amount = @game.to_call

    if @total_in_pot == amount
      amount = [@total_in_pot - amount, 0].max
    end

    # small blind
    if self == @game.small_blind_player
      return [amount - @game.small_blind, 0].max
    end

    # big blind
    if self == @game.big_blind_player
      return [amount - @game.big_blind, 0].max
    end

    return amount
  end

  def call
    return false unless valid_action?(:call)

    amount = to_call

    if amount > @chips
      error("not enough chips to call, go all in?")
      return false
    end

    @chips -= amount
    @action = :call

    @game.call(self, amount)

    @total_in_pot += amount

    return true
  end

  def raise(amount)
    return unless valid_action?(:raise)

    # to raise we must pay to call
    amount = @game.to_call + amount

    if amount > @chips
      error("not enough chips to raise #{amount}, go all in?")
      return false
    end

    return false unless @game.raise(self, amount)

    @chips -= amount
    @action = :raise
    @last_bet = amount
    @total_in_pot += amount

    return true
  end

  def fold
    if not @@actions[@game.table_state].include?(:fold)
      error("cannot fold when game.table_state == #{@game.table_state}")
      return false
    end

    @action = :fold

    @game.fold(self)

    return true
  end

  def check
    if not @@actions[@game.table_state].include?(:check) and @position != 2
      error("cannot check when game.table_state == #{@game.table_state}")
      return false
    end

    @action = :check
    @game.check(self)

    return true
  end

  def all_in
    if not @@actions[@game.table_state].include?(:all_in)
      error("cannot all_in when game.table_state == #{@game.table_state}")
      return false
    end

    @game.last_bet = @chips
    @total_in_pot += chips
    @chips = 0

    return true
  end

  def available_actions
    if self == @game.big_blind_player and @game.table_state == :call
      actions = @@actions[@game.table_state].clone
      actions.delete(:call)
      actions.delete(:fold)
      actions << :check
      return actions
    end

    if (@position > 2 or @position == 0) and @@actions[@game.table_state].include?(:post_blind) == true
      return []
    end

    @@actions[@game.table_state]
  end

  def to_s
    case position
    when 0
      pos_name = "dealer"
    when 1
      pos_name = "small_blind"
    when 2
      pos_name = "big_blind"
    else
      pos_name = "dealer+#{position}"
    end

    "Player '#{pos_name}': (chips: #{@chips}, pot: #{@total_in_pot}, last bet: #{@last_bet}, state: #{@state})"
  end

private
  def valid_action?(action)
    if not available_actions.include?(action)
      error("cannot #{action} when game.table_state == #{@game.table_state}")
      return false
    else
      return true
    end
  end
end
