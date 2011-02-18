class Card
  attr_reader :suit, :rank

  def initialize(suit, rank)
    @suit     = suit
    @rank     = rank
    @facedown = true
  end

  def facedown?
    @facedown
  end

  def flip
    @facedown = false
  end

end