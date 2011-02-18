class Player
  attr_accessor :position, :chips, :action

  # game state => player actions
  @@actions = {
    :post_blind => [:post_blind],
    :bet        => [:call, :bet, :raise, :fold, :all_in],  # big blind can check
    :check      => [:raise, :fold, :check, :all_in],
    :raise      => [:call, :fold, :raise, :all_in],
  }

  def initialize(game, chips)
    @game     = game
    @chips    = chips
    @state    = :bet
    @actions  = []
    @position = nil
    @last_bet = 0
  end

  def error(msg)
    puts "ERROR (Player #{@position}): #{msg}"
  end

  def debug(msg)
    puts "DEBUG (Player #{@position}): #{msg}"
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
    @game.post_blind(amount)
    @action = :post_blind
    @last_bet = amount

    debug("posted blind")

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
    @game.bet(amount)

    debug("bet #{amount}")
    return true
  end

  def to_call
    # small blind
    if @position == 1
      return @game.to_call - @game.small_blind
    end

    # big blind
    if @position == 2
      return [@game.to_call - @game.big_blind, 0].min
    end

    return @game.to_call
  end

  def call
    if not @@actions[@game.state].include?(:call)
      error("cannot call when game.state == #{@game.state}")
      return false
    end

    if @game.to_call > @chips
      error("not enough chips to call, go all in?")
      return false
    end

    @chips -= to_call
    @game.pot += to_call
    @action = :call
    @last_bet = to_call

    debug("called with #{to_call}")

    return true
  end

  def raise(amount)
    if not @@actions[@game.state].include?(:raise)
      error("cannot raise when game.state == #{@game.state}")
      return false
    end

    if amount > @chips
      error("not enough chips to raise #{amount}, go all in?")
      return false
    end

    if amount <= @game.to_call
      error("must raise more than call amount")
      return false
    end

    @chips -= amount
    @action = :raise
    @last_bet = amount

    @game.raise(amount)

    debug("raised #{to_call}")

    return true
  end

  def fold
    if not @@actions[@game.state].include?(:fold)
      error("cannot fold when game.state == #{@game.state}")
      return false
    end

    @action = :fold
    @last_bet = 0

    @game.fold

    debug("folded")

    return true
  end

  def check
    if not @@actions[@game.state].include?(:check) and @position != 2
      error("cannot check when game.state == #{@game.state}")
      return false
    end

    @action = :check
    @game.state = :check
    @last_bet = 0

    debug("checked")

    return true
  end

  def all_in
    if not @@actions[@game.state].include?(:all_in)
      error("cannot all_in when game.state == #{@game.state}")
      return false
    end

    debug "all in with #{@chips}"

    @game.pot += @chips
    @game.last_bet = @chips
    @last_bet = @chips
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
end