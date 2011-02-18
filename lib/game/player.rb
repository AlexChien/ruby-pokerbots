class Player
  attr_accessor :position, :chips, :action
  attr_reader :total_in_pot

  # game state => player actions
  @@actions = {
    :post_blind => [:post_blind],
    :bet        => [:call, :bet, :raise, :fold, :all_in],  # big blind can check
    :check      => [:raise, :check, :all_in],
    :raise      => [:call, :fold, :raise, :all_in],
  }

  def initialize(game, chips)
    @game     = game
    @chips    = chips
    @state    = :bet
    @actions  = []
    @position = nil
    @last_bet = 0
    @total_in_pot = 0
  end

  def error(msg)
    puts "ERROR (Player #{@position}): #{msg}"
  end

  def post_blind
    if not @@actions[@game.state].include?(:post_blind)
      error("cannot bet when game.state == #{@game.state}")
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

  def bet(amount)
    if not @@actions[@game.state].include?(:bet)
      error("cannot bet when game.state == #{@game.state}")
      return false
    end

    if @position == 1
      amount -= @game.small_blind
    end

    if @position == 2
      amount -= @game.big_blind
    end

    if(amount <= @game.big_blind)
      error("must bet more than the big blind")
      return false
    end

    if amount > @chips
      error("cannot bet #{amount} > #{@chips}")
      return false
    end

    @chips -= amount
    @action = :bet
    @game.bet(self, amount)
    @total_in_pot += amount

    return true
  end

  def to_call
    if @action == :raise and @game.state == :raise
      amount = [@game.to_call - @total_in_pot, 0].max
    else
      amount = @game.to_call
    end

    # small blind
    if @position == 1
      return [amount - @game.small_blind, 0].max
    end

    # big blind
    if @position == 2
      return [amount - @game.big_blind, 0].max
    end

    return amount
  end

  def call
    return unless valid_action?(:call)

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

    # this is a reraise
    if @game.state == :raise
      amount += @game.to_call
    end

    if amount > @chips
      error("not enough chips to raise #{amount}, go all in?")
      return false
    end

    prev_state= @game.state
    return false unless @game.raise(self, amount)

    @chips -= amount
    @action = :raise
    @last_bet = amount
    @total_in_pot += amount

    return true
  end

  def fold
    if not @@actions[@game.state].include?(:fold)
      error("cannot fold when game.state == #{@game.state}")
      return false
    end

    @action = :fold

    @game.fold(self)

    return true
  end

  def check
    if not @@actions[@game.state].include?(:check) and @position != 2
      error("cannot check when game.state == #{@game.state}")
      return false
    end

    @action = :check
    @game.check(self)

    return true
  end

  def all_in
    if not @@actions[@game.state].include?(:all_in)
      error("cannot all_in when game.state == #{@game.state}")
      return false
    end

    @game.last_bet = @chips
    @total_in_pot += chips
    @chips = 0

    return true
  end

  def available_actions
    if @position == 2 and (@@actions[@game.state].include?(:check) == false and @game.state != :post_blind)
      return @@actions[@game.state] + [:check]
    end

    if (@position > 2 or @position == 0) and @@actions[@game.state].include?(:post_blind) == true
      return []
    end

    @@actions[@game.state]
  end

private
  def valid_action?(action)
    if not @@actions[@game.state].include?(action)
      error("cannot #{action} when game.state == #{@game.state}")
      return false
    else
      return true
    end
  end

end