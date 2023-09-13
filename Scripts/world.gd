extends Node2D

var gameover = false
var game_won = false

@onready var pigs_node = $Level/Pigs
@onready var villagers_node = $Level/Villagers
@onready var graphs_node = $Level/graphPanel
@onready var pig = preload("res://Scenes/Pig.tscn")
@onready var villager = preload("res://Scenes/villager.tscn")
@onready var graphs = preload("res://Scenes/graphs.tscn")
@onready var island_map = $Level/IslandMap
@onready var popup_control = $infoPopUps/popupControl

func _ready():
	# Here there could be a spawner for Area2d nodes with stats associated to them
	# underneath each tile -> corresponds to datalayer
	# in a dictionary, all values of the corresponding tile are stored
	# OR: just make a dictionary in the first place, key them to each used tile
	# to ensure access... yo, true, don't need any new layer for that.
	# Only setup of "Data Layer" here....
	Game.data_layer.clear() # to make sure no leftover data after restart
	establish_data_map()
	# fire the tutorial popups and pause game
	pause_game()
	# spawn an initial amount of little guys
	spawn_villager(10)
	spawn_pigs(2)

	popup_control.get_child(2).fired = true
	popup_control.get_child(2).show()
	
	
func establish_data_map():
	# CAN REPLACE THIS WITH GAME tt_TYPE DEFAULTS!?
	# the mapping.gd script could be incorporated here (or vice versa)
	for pos_vector in Game.tile_list:
		var data = island_map.get_cell_tile_data(0, pos_vector)
		var data_type = data.get_custom_data("Type")
		if data_type == "Grassland":
			if pos_vector not in Game.data_layer:
				Game.data_layer[pos_vector] = {
					"type": "grass", 
					"underbrush": 50, 
					"trees": 50,
					"ub_tree_growth_factor": Game.ub_tree_growth_factor,
					"tree_ub_growth_factor": Game.tree_ub_growth_factor,
					"surround_modifier": Game.surround_modifier,
					"atlas_coord": Vector2i(0, 0)# store this here for easy access to tile art
					}
		elif data_type == "Forest":
			if pos_vector not in Game.data_layer:
				Game.data_layer[pos_vector] = {
					"type": "forest", 
					"underbrush": 100, 
					"trees": 100,
					"ub_tree_growth_factor": Game.ub_tree_growth_factor,
					"tree_ub_growth_factor": Game.tree_ub_growth_factor,
					"surround_modifier": Game.surround_modifier,
					"atlas_coord": Vector2i(10, 5) 
					}
		elif data_type == "Desolation":
			if pos_vector not in Game.data_layer:
				Game.data_layer[pos_vector] = {
					"type": "desolation", 
					"underbrush": 0, 
					"trees": 0,
					"ub_tree_growth_factor": Game.ub_tree_growth_factor,
					"tree_ub_growth_factor": Game.tree_ub_growth_factor,
					"surround_modifier": Game.surround_modifier,
					"atlas_coord": Vector2i(6, 2)
					}
	print("Datamap initialized.")

func restart(): # I THINK it works now, yey

	var go_to_animal_sanctuary = get_tree().get_nodes_in_group("pigs_group")
	for pig in go_to_animal_sanctuary:
		pig.queue_free()
	
	var sail_away = get_tree().get_nodes_in_group("villagers_group")
	for villager in sail_away:
		villager.queue_free()
	
	var popup_counter = popup_control.get_child_count() - 1
	
	while popup_counter >= 0:
		popup_control.get_child(popup_counter).fired = false
		popup_counter -= 1
	
	get_tree().reload_current_scene()
	Game.global_threshold = 0
	Game.wood = 0
	Game.ticks = 0 # reset ticks
	Game.zufriedenheit = 0
	if Game.alltime_highscore < Game.current_highscore:
		Game.alltime_highscore = Game.current_highscore
	Game.current_highscore = 0
	gameover = false
	game_won = false
	print("Wir besiedeln eine neue Insel!")
	#get_tree().change_scene_to_file("res://Scenes/main.tscn")
	
func _process(delta):
	# fire first info panel when first desolation appears
	if Game.deso_amount == 1 and Game.ticks > 1  and popup_control.get_child(0).fired == false:
		pause_game()
		popup_control.get_child(0).fired = true
		popup_control.get_child(0).show()
	if Game.grass_amount == 200 and Game.ticks > 1  and popup_control.get_child(1).fired == false:
		pause_game()
		popup_control.get_child(1).fired = true
		popup_control.get_child(1).show()
	if Game.average_tree_cover <= 67.00 and Game.ticks > 1 and popup_control.get_child(4).fired == false:
		pause_game()
		popup_control.get_child(4).fired = true
		popup_control.get_child(4).show()
	if Game.deso_percent >= 50.00 and Game.ticks > 1 and popup_control.get_child(5).fired == false:
		pause_game()
		popup_control.get_child(5).fired = true
		popup_control.get_child(5).show()
		
	# if max piggies near popup
	if Game.pigHerd >= int(Game.max_pigs / 2 - 10 ) and Game.ticks > 1 and popup_control.get_child(7).fired == false:
		pause_game()
		popup_control.get_child(7).fired = true
		popup_control.get_child(7).show()
		print("Achtung, piggy threshold incoming!")
		
	# Game over screen popups!
	if Game.deso_percent == 100 and Game.ticks > 1 and popup_control.get_child(6).fired == false:
		game_over()
		
	if Game.pigHerd >= Game.max_pigs and Game.ticks > 1 and popup_control.get_child(6).fired == false:
		game_over()

	if Game.villager_count <= 0 and Game.ticks > 1:
		game_over()
	
	
func game_over():
	# This fires when the game is lost / the island is destroyed
	pause_game()
	popup_control.get_child(6).fired = true
	popup_control.get_child(6).show()
	popup_control.get_child(6).get_child(1).hide()
	gameover = true
	
	popup_control.get_child(8).fired = true
	popup_control.get_child(8).show()
	
	# Your highscore is set to 0, because you FAILED to save the island long enough
	Game.current_highscore = 0 
	
func spawn_villager(amount):
	for x in range(0, amount):
		var villTemp = villager.instantiate()
		#var rand_pos = Game.legal_tiles[randi() % Game.legal_tiles.size()]
		#rand_pos = island_map.local_to_map(rand_pos)
		var rand_xy = Vector2i(randi_range(300,400), randi_range(200,400))
		#var rand_xy = Vector2i(randi_range(300,400), randi_range(200,400))
		villTemp.position = rand_xy
		villTemp.velocity = Vector2.ZERO
		# important to put new pig as child on Pigs 2Dnode to make sure the
		# node paths are working!
		# TODO: rewrite this to use signals, so positions become irrelevant
		villagers_node.add_child(villTemp)
		villTemp.add_to_group("villagers_group")

func spawn_pigs(amount):
	for x in range(0, amount):
		var pigTemp = pig.instantiate()
		var rand_xy = Vector2i(randi_range(300,400), randi_range(200,400))
		pigTemp.position = rand_xy
		
		# important to put new pig as child on Pigs 2Dnode to make sure the
		# node paths are working!
		# TODO: rewrite this to use signals, so positions become irrelevant
		pigs_node.add_child(pigTemp)
		pigTemp.add_to_group("pigs_group")

func despawn_pigs(amount: int):
	if Game.pigHerd > 0:
		var all_pigs = get_tree().get_nodes_in_group("pigs_group")
		for x in range(0, amount):
			var pig_to_migrate = all_pigs.pop_front()
			pig_to_migrate.queue_free()

	
# spawn one pig on random position
func _on_pig_spawn_pressed():
	var amount = 1
	spawn_pigs(amount)

func _input(event):
	
	if event.is_action_pressed("add_pig"):
		spawn_pigs(1)
	elif event.is_action_pressed("super_pig"):
		spawn_pigs(10)
		
	elif event.is_action_pressed("pause_game"):
		if gameover == false:
			pause_game()
			
	elif event.is_action_pressed("restart_game"):
		restart() 
	elif event.is_action_pressed("ship_pig"):
		despawn_pigs(1)
	
	elif event.is_action_pressed("feast_pigs"):
		if $Level/GUI/HBoxContainer/Buttons/PigFeast.disabled == false:
			_on_pig_feast_pressed()
		
	elif event.is_action_pressed("right_click"):
		
		for popup in popup_control.get_children():
			popup.hide()
		pause_game()
		
	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()
			
func pause_game():
	var pause_value = get_tree().paused
	get_tree().paused = !pause_value
	#print("Pause button pressed ")
	if get_tree().paused == true:
		print("Game paused")
	else:
		print("Game unpaused")
		for popup in popup_control.get_children():
			popup.hide()
		
# delete half the pigs (with cooldown?)
func _on_pig_feast_pressed():
	var to_cull = int(len(get_tree().get_nodes_in_group("pigs_group")) / 2)
	despawn_pigs(to_cull)
	$Level/GUI/HBoxContainer/Buttons/PigFeast/feast_cooldown.start()
	$Level/GUI/HBoxContainer/Buttons/PigFeast.disabled = true

func _on_button_pressed():
	# Tutorial "Weiter..." Button
	#print("click!")
	popup_control.get_child(2).hide()
	popup_control.get_child(3).fired = true
	popup_control.get_child(3).show()


func _on_start_button_pressed():
	popup_control.get_child(3).hide()
	pause_game()

func _on_button_start_pressed():
	pause_game()


func _on_pig_kill_some_pressed():
	despawn_pigs(1)


func _on_lvl_timer_timeout():
	# count healthy pigs, spawn 1 new pig for each 2 healthy pigs
	var reproduce_pigs = get_tree().get_nodes_in_group("pigs_group").size()
	reproduce_pigs = int(reproduce_pigs / 2)
	spawn_pigs(reproduce_pigs)
	
	# adjust the score - replace highscore if higher
	var tick_score = Game.pigHerd + Game.wood + (Game.forest_percent - 50 ) - Game.deso_amount
	var new_score = Game.zufriedenheit + tick_score
	if Game.current_highscore < new_score:
		Game.current_highscore = new_score
	Game.zufriedenheit = new_score


func _on_feast_cooldown_timeout():
	$Level/GUI/HBoxContainer/Buttons/PigFeast.disabled = false

func _on_gameover_timer_timeout():
	game_completed()

func game_completed():
	# This gets used when the game is completed successfully -> only then the current highscore counts!
	pause_game()
	gameover = true
	game_won = true
	
	# check threshold state and deduct points if necessary
	if Game.threshold_level == "yellow":
		Game.current_highscore = int(Game.current_highscore * 0.67)
	elif Game.threshold_level == "red":
		Game.current_highscore = int(Game.current_highscore * 0.34)
	elif Game.threshold_level == "black":
		Game.current_highscore = int(Game.current_highscore * 0.1)

	
	popup_control.get_child(6).fired = true
	popup_control.get_child(6).show()
	popup_control.get_child(6).get_child(0).hide()
	
func _on_to_game_over_1_pressed():
	# Go to GameOver1 popup
	popup_control.get_child(6).hide()
	popup_control.get_child(8).fired = true
	popup_control.get_child(8).show()

func _on_to_game_over_2_pressed():
	# Go to GameOver2 popup
	popup_control.get_child(8).hide()
	popup_control.get_child(9).fired = true
	popup_control.get_child(9).show()

func _on_to_game_over_3_pressed():
	# Go to GameOver3 popup
	popup_control.get_child(9).hide()
	popup_control.get_child(10).fired = true
	popup_control.get_child(10).show()

func _on_to_game_over_4_pressed():
	# Go to GameOver4 popup
	popup_control.get_child(10).hide()
	popup_control.get_child(11).fired = true
	popup_control.get_child(11).show()
	if game_won != true:
		popup_control.get_child(11).get_child(2).hide()

func _on_new_game_pressed():
	pause_game()
	restart()



