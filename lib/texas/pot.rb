class Pot
  attr_reader :chips, :blind

  def initialize(blind)
    @blind = blind
    @chips = 0
  end
  
  def add(chips)
    @chips += chips
  end
end