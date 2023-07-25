extends Node2D

@onready var pigs_node = $Pigs
@onready var villagers_node = $Villagers
@onready var pig = preload("res://Scenes/Pig.tscn")
@onready var villager = preload("res://Scenes/villager.tscn")
@onready var island_map = $IslandMap

func _ready():
	# Here there could be a spawner for Area2d nodes with stats associated to them
	# underneath each tile -> corresponds to datalayer
	# in a dictionary, all values of the corresponding tile are stored
	# OR: just make a dictionary in the first place, key them to each used tile
	# to ensure access... yo, true, don't need any new layer for that.
	# Only setup of "Data Layer" here....
	establish_data_map()
	# these are all keys for used cells, including sea.
	
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
					"underbrush": 100, 
					"trees": 30,
					"tree_growth_modifier": 0.5, # trees regrow slower on grass
					"ub_tree_growth_factor": Game.ub_tree_growth_factor,
					"ub_growth_modifier": 0.3, # ub regrow slower on grass
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
					"tree_growth_modifier": 1.5, # trees grow faster in woods
					"ub_tree_growth_factor": Game.ub_tree_growth_factor,
					"ub_growth_modifier": 0.3,
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
					"tree_growth_modifier": 0, # trees won't regrow here; lack of underbrush will kill of remaining
					"ub_tree_growth_factor": Game.ub_tree_growth_factor,
					"ub_growth_modifier": 1, # ub won't regrow here; lack of trees will kill of remaining
					"tree_ub_growth_factor": Game.tree_ub_growth_factor,
					"surround_modifier": Game.surround_modifier,
					"atlas_coord": Vector2i(6, 2)
					}
	print("Datamap initialized.")

func restart(): # BUGGY!

	var to_slaugther = get_tree().get_nodes_in_group("pigs_group")
	for pig in to_slaugther:
		pig.queue_free()
	get_tree().reload_current_scene()
	get_node("IslandMap").request_ready()

	establish_data_map()
	# hmm this doesn't work as intended
	
func _process(delta):
	update_herdsize()
	update_map() # this needs to go elsewhere, regrowth is way too fast
	if Input.is_action_just_pressed("restart_game"):
		restart()


# update the herdsizes etc. to be displayed
func update_herdsize():
	Game.pigs = get_tree().get_nodes_in_group("pigs_group")
	Game.pigHerd = Game.pigs.size()

# spawn one pig on random position
func _on_pig_spawn_pressed():
	var pigTemp = pig.instantiate()

	pigTemp.position = Vector2i(400, 300)
	# important to put new pig as child on Pigs 2Dnode to make sure the
	# node paths are working!
	# TODO: rewrite this to use signals, so positions become irrelevant
	pigs_node.add_child(pigTemp)
	pigTemp.add_to_group("pigs_group")

# delete all pigs on button press
func _on_pig_feast_pressed():
	var to_slaugther = get_tree().get_nodes_in_group("pigs_group")
	for pig in to_slaugther:
		pig.queue_free()

func hover_tile_info():
	# here I'd like to build a small little function to display the tile
	# data that Im hovering over/click, to check sanity of pig behavior/cell changes
	pass

func update_map():
	"""Function to update tile types at certain intervalls"""
	# perhaps need to connect to timer node?!
	# maybe this could somehow be more sensibly/performance savingly done with signals?!
	# should this be on Game-layer?!
	
	#IF time has come:
	for entry in Game.data_layer:
		
		# check if surrounding tiles change any data
		check_surr_tiles(entry)
		
		# define 3 thresholds of underbrush that influence tree growth
		# this could be done more smoothly... 
		if Game.data_layer[entry].underbrush >= 67:
			Game.data_layer[entry].ub_tree_growth_factor = 1
		elif Game.data_layer[entry].underbrush >= 34:
			Game.data_layer[entry].ub_tree_growth_factor = 0
		elif Game.data_layer[entry].underbrush <= 33:
			Game.data_layer[entry].ub_tree_growth_factor = - 2
			
		# make trees grow according to variables/tile type (modifiers baked in)
		Game.data_layer[entry].trees = snapped(clamp( # clamp to min max values
			(Game.data_layer[entry].trees + (
				Game.tree_growth * # default tree growth amount
				Game.data_layer[entry].tree_growth_modifier * # tile type dependant tree growth modifier
				Game.data_layer[entry].ub_tree_growth_factor # underbrush factor; also ub 80 -> factor 0,3; ub 30 -> factor -0,2; between -0.5 and 0.5
				# this is linear, which is suboptimal, but ok i guess?!
				# Ideally there should be a clever equation that leads to high levels of underbrush leading
				# to default levels of tree growth and increasingly bad levels of tree growth with low underbrush
				# Alternative thought: actually, low levels of underbrush are not a problem, it actually
				# means more space and light for the remaining little trees; so linear might be fine anyway 
				) +
				Game.data_layer[entry].surround_modifier
			),
			Game.min_forest, Game.max_forest
			), 0.01)
		
		# define 3 thresholds of tree amount that influences underbrush growth
		# this could be done more smoothly... 
		if Game.data_layer[entry].underbrush >= 76: # not as much growth if many trees
			Game.data_layer[entry].tree_ub_growth_factor = 0
		elif Game.data_layer[entry].underbrush >= 26: # good growth if some trees
			Game.data_layer[entry].tree_ub_growth_factor = 1
		elif Game.data_layer[entry].underbrush <= 25: # sharp decline if not enough trees
			Game.data_layer[entry].tree_ub_growth_factor = - 3
		
		# make underbrush grow according to variables
		Game.data_layer[entry].underbrush = snapped(clamp(
			(Game.data_layer[entry].underbrush + (
				Game.default_underbrush_growth + # default UB growth amount
				Game.data_layer[entry].ub_growth_modifier * # do we need more in depth ub regrowth?!
				Game.data_layer[entry].tree_ub_growth_factor 
				) +
				Game.data_layer[entry].surround_modifier
			),
			Game.min_underbrush, Game.max_underbrush
			), 0.01)
		
		# the following need to be converted into default values....
		if Game.data_layer[entry].type == "forest":
			if Game.data_layer[entry].trees <= 50:
				"""If not enough trees -> this tile is now grassland"""
				Game.data_layer[entry].type = "grass"
				island_map.set_cell(0, Vector2i(entry), 3, Vector2i(0, 0))
				Game.data_layer[entry].atlas_coord = Vector2i(0, 0)
				Game.data_layer[entry].tree_growth_modifier = 0.5
				Game.data_layer[entry].ub_growth_modifier = 0.3

			
			elif Game.data_layer[entry].trees <= 1:
				"""If barely any trees -> this tile is now desolation"""
				island_map.set_cell(0, Vector2i(entry), 3, Vector2i(6, 2))
				Game.data_layer[entry].type = "desolation"
				Game.data_layer[entry].atlas_coord = Vector2i(6, 2)
				Game.data_layer[entry].tree_growth_modifier = 1
				Game.data_layer[entry].ub_growth_modifier = 1
		
		elif Game.data_layer[entry].type == "grass":
			if Game.data_layer[entry].trees >= 50:
				"""If enough trees regrew -> this tile is now forest"""
				Game.data_layer[entry].type = "forest"
				island_map.set_cell(0, Vector2i(entry), 3, Vector2i(10, 5))
				Game.data_layer[entry].atlas_coord = Vector2i(10, 5)
				Game.data_layer[entry].tree_growth_modifier = 1.5
				Game.data_layer[entry].ub_growth_modifier = 1.3

			
			elif Game.data_layer[entry].trees <= 1:
				"""If barely any trees -> this tile is now desolation"""
				island_map.set_cell(0, Vector2i(entry), 3, Vector2i(6, 2))
				Game.data_layer[entry].type = "desolation"
				Game.data_layer[entry].atlas_coord = Vector2i(6, 2)
				Game.data_layer[entry].tree_growth_modifier = - 1
				Game.data_layer[entry].ub_growth_modifier = - 1

func check_surr_tiles(tile_data):
	"""This is a check each tile performs in certain interval to see if neighborhood is healthy"""
	# If not, the tile itself either grows less or actually decreases 
	# this should lead to some cascading breakdowns of grass/forest, nyahaha
	# HOWEVER: this should use some of the processes in update_map/be part of it, since
	# it needs the same info.... but thats getting pretty big. hm.
	var neighbor_list = []
	var forest_count = 0
	var deso_count = 0
	
	# get neighbor tile types
	# Moore neighborhood (more performance cost this way... but also more dynamic)
	var north_tile = tile_data + Vector2i(0, 1) 
	if north_tile in Game.data_layer:
		neighbor_list.append(Game.data_layer[north_tile].type)
	
	# northwest and northeast tiles
	var nw_tile = north_tile + Vector2i(-1, 0) 
	if nw_tile in Game.data_layer:
		neighbor_list.append(Game.data_layer[nw_tile].type)
	var ne_tile = north_tile + Vector2i(1, 0) 
	if ne_tile in Game.data_layer:
		neighbor_list.append(Game.data_layer[ne_tile].type)
	
	# south tile
	var south_tile = tile_data + Vector2i(0, -1)
	if south_tile in Game.data_layer:
		neighbor_list.append(Game.data_layer[south_tile].type)
	
	# south west and south east tiles
	var sw_tile = south_tile + Vector2i(-1, 0) 
	if sw_tile in Game.data_layer:
		neighbor_list.append(Game.data_layer[sw_tile].type)
	var se_tile = south_tile + Vector2i(1, 0) 
	if se_tile in Game.data_layer:
		neighbor_list.append(Game.data_layer[se_tile].type)
			
	# west and east tile
	var west_tile = tile_data + Vector2i(-1, 0)
	if west_tile in Game.data_layer:
		neighbor_list.append(Game.data_layer[west_tile].type)
	var east_tile = tile_data + Vector2i(1, 0)
	if east_tile in Game.data_layer:
		neighbor_list.append(Game.data_layer[east_tile].type)
	
	# Count neighbor types
	for neighbor in neighbor_list:
		if neighbor == "forest":
			forest_count += 1
		elif neighbor == "desolation":
			deso_count += 1
	
	# if 3 or more forest -> growth ++
	# if 2 forest -> growth =
	# if less than 2 forest -> growth --
	# if 3 or more desolation -> growth -----
	var local_tile = Game.data_layer[tile_data]
	#if forest_count >= 4: # if on 4 or more sides forest -> growth increase
		#local_tile.ub_growth_modifier = local_tile.ub_growth_modifier + 0.5
	#elif forest_count <= 2: 
		#local_tile.ub_growth_modifier = local_tile.ub_growth_modifier + 0.25
	if deso_count >= 1: # if on 2 or more sides desolation -> trees start dying
		local_tile.surround_modifier = - 1
	elif deso_count >= 3: # if on 4 or more sides desolation -> trees start dying
		local_tile.surround_modifier = - 4
	elif deso_count >= 5: # if on 6 or more sides desolation -> trees start dying
		local_tile.surround_modifier = - 16
