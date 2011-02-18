class Table
  attr_accessor :state

  @@states = [
    :pre_flop,
    :flop,
    :turn,
    :river,
    :showdown
  ]

  def initialize
    @state      = :pre_flop
    @flop_cards = []
    @turn_card  = nil
    @river_card = nil
  end
end