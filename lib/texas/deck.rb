class Deck
  attr_reader :deck

  def initialize
    @deck = [
      'Ac' , 'Ah' , 'Ad' , 'As',
      'Kc' , 'Kh' , 'Kd' , 'Ks',
      'Qc' , 'Qh' , 'Qd' , 'Qs',
      'Jc' , 'Jh' , 'Jd' , 'Js',
      '10c', '10h', '10d', '10s',
      '9c' , '9h' , '9d' , '9s',
      '8c' , '8h' , '8d' , '8s',
      '7c' , '7h' , '7d' , '7s',
      '6c' , '6h' , '6d' , '6s',
      '5c' , '5h' , '5d' , '5s',
      '4c' , '4h' , '4d' , '4s',
      '3c' , '3h' , '3d' , '3s',
      '2c' , '2h' , '2d' , '2s',
    ]
  end

  def shuffle
    7.times do
      (@deck.size-1).downto(1) do |i|
        ri = rand(i+1) # ruby's rand good enough? doubt it
        card = @deck[i]
        @deck[i] = @deck[ri]
        @deck[ri] = card
      end
    end
  end

  def deal
    card = @deck.shift
    @deck.push card
    return card
  end
end