class Table
  attr_reader :state

  @@states = {
    :pre_flop => :flop,
    :flop     => :turn,
    :turn     => :river,
    :river    => :showdown
  }

  def initialize
    @state      = :pre_flop
    @flop_cards = []
    @turn_card  = nil
    @river_card = nil
  end
  
  def next_deal
    @state = @@states[state]
  end
end
