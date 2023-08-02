extends Node2D

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
	Game.data_layer.clear()
	establish_data_map()
	# these are all keys for used cells, including sea.
	spawn_villager(10)
	spawn_pigs(10)
	pause_game()
	popup_control.get_child(2).fired = true
	popup_control.get_child(2).show()
	
	
func establish_data_map():
	# this creates all key-value dicts for all usable tiles 
	# will have to refactor to look for terrain layer to distinguish
	# possible other tiles (Map rewrite necessary)
	var all_tile_list = island_map.get_used_cells_by_id(0)
	
	# CAN REPLACE THIS WITH GAME tt_TYPE DEFAULTS!
	# the mapping.gd script could be incorporated here (or vice versa)
	for pos_vector in all_tile_list:
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
	
	
	get_tree().reload_current_scene()
	Game.global_threshold = 0
	Game.ticks = 0 # reset ticks
	print("Wir besiedeln eine neue Insel!")
	


func _process(delta):
	# fire first info panel when first desolation appears
	if Game.deso_amount == 1 and popup_control.get_child(0).fired == false:
		pause_game()
		popup_control.get_child(0).fired = true
		popup_control.get_child(0).show()
	if Game.grass_amount == 200 and popup_control.get_child(1).fired == false:
		pause_game()
		popup_control.get_child(1).fired = true
		popup_control.get_child(1).show()
				

	
func spawn_villager(amount):
	for x in range(0, amount):
		var villTemp = villager.instantiate()
		#var rand_xy = Vector2i(randi_range(300,400), randi_range(200,400))
		villTemp.position = Vector2i(400, 300)
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
	var all_pigs = get_tree().get_nodes_in_group("pigs_group")
	for x in range(0, amount):
		var pig_to_migrate = all_pigs.pop_front()
		print(pig_to_migrate)
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
		pause_game()
			
	elif event.is_action_pressed("restart_game"):
		restart() 
	
	elif event.is_action_pressed("right_click"):
		
		for popup in popup_control.get_children():
			popup.hide()
		pause_game()
			
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
		
# delete all pigs on button press
func _on_pig_feast_pressed():
	var to_cull = len(get_tree().get_nodes_in_group("pigs_group"))
	despawn_pigs(to_cull)

func hover_tile_info():
	# here I'd like to build a small little function to display the tile
	# data that Im hovering over/click, to check sanity of pig behavior/cell changes
	pass


func _on_button_pressed():
	print("click!")
	popup_control.get_child(2).hide()
	popup_control.get_child(3).fired = true
	popup_control.get_child(3).show()


func _on_button_start_pressed():
	print("click-ity!")
	popup_control.get_child(3).hide()
	pause_game()


func _on_pig_kill_some_pressed():
	despawn_pigs(1)
