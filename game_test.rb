require './lib/poker'

game = Game.new(10, 15)

4.times do
  game.add_player(Player.new(game, 100))
end

game.start

game.big_blind_player.post_blind
game.small_blind_player.post_blind

3.times do
  player = game.next_player
  p player.cards
  player.call
end

game.deal

p game.table_cards

4.times do
  game.next_player.check
end

game.deal

p game.table_cards

4.times do
  game.next_player.check
end

game.deal

p game.table_cards