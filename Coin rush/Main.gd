extends Node

export (PackedScene) var Coin
export (PackedScene) var Powerup
export (PackedScene) var Powerup2
export (int) var playtime

var level
var score
var time_left
var screensize 
var playing = false


# Hides player on launch 
func _ready():
	randomize()
	screensize = get_viewport().get_visible_rect().size
	$Player.screensize = screensize
	$Player.hide()


# Starts the game
func new_game():
	playing = true
	level = 1
	score = 0
	time_left = playtime
	$Player.start($Player.position)
	$Player.show()
	$GameTimer.start()
	$HUD.update_score(score)
	$HUD.update_timer(time_left)
	spawn_coins()


# Spawns the coins
func spawn_coins():
	$LevelSound.play()
	for i in range (4 + level):
		var c = Coin.instance()
		$CoinContainer.add_child(c)
		c.screensize = screensize
		c.position = Vector2(rand_range(0, screensize.x), 
		rand_range(0, screensize.y))


# Checks if the game is running and if all coins have been collected
func _process(delta):
	if playing and $CoinContainer.get_child_count() == 0:
		level += 5
		spawn_coins()
		$PowerupTimer.wait_time = rand_range(3, 8)
		$PowerupTimer.start()


# Controls game timer
func _on_GameTimer_timeout():
	time_left -= 1
	$HUD.update_timer(time_left)
	if time_left <= 0:
		game_over()


# Ends game id player is hurt
func _on_Player_hurt():
	game_over()


# Checks for pickup type
func _on_Player_pickup(type):
	match type:
		"coin":
			score += 1
			$HUD.update_score(score)
			$CoinSound.play()
		"powerupSpeed":
			$Player.speed += 350
			$PowerupSound.play()
			$PowerDurationTimer.start()
		"powerupTime":
			time_left += 5
			$PowerupSound.play()
			$HUD.update_timer(time_left)


# Ending sequence
func game_over():
	playing = false
	$GameTimer.stop()
	for coin in $CoinContainer.get_children():
		coin.queue_free()
	$HUD.show_game_over()
	$Player.die()
	$EndSound.play()


# Powerup generation
func _on_PowerupTimer_timeout():
	var i = randi() % 2 # Generate either 0 or 1
	if i == 0:
		# Speed powerup
		var p = Powerup.instance()
		add_child(p)
		p.screensize = screensize
		p.position = Vector2(rand_range(0, screensize.x), 
		rand_range(0, screensize.y))
	else:
		# Time powerup
		var t = Powerup2.instance()
		add_child(t)
		t.screensize = screensize
		t.position = Vector2(rand_range(0, screensize.x), 
		rand_range(0, screensize.y))


# Reset the players speed
func _on_PowerDurationTimer_timeout():
	$Player.speed -= 350
