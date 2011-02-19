module SpecUtils

  def self.post_blinds(game)
    game.big_blind_player.post_blind
    game.small_blind_player.post_blind
  end

  def self.raise_state(game, amount)
    post_blinds(game)
    game.next_player.raise(amount)
  end

  def self.calls_to_small_blind(game, players_count)
    post_blinds(game)

    (players_count - 2).times do
      game.next_player.call
    end
  end

  def self.calls_to_big_blind(game, players_count)
    post_blinds(game)

    (players_count - 1).times do
      game.next_player.call
    end
  end

  def self.everyone_calls(game, players_count)
    post_blinds(game)

    players_count.times do
      game.next_player.call
    end
  end

  def self.everyone_calls_complex(game, players_count)
    post_blinds(game)
    game.next_player.raise(15)
    players_count.times do
      game.next_player.call
    end
  end

end