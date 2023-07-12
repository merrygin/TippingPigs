extends Node2D

@onready var pigs_node = $Pigs
@onready var pig = preload("res://Scenes/Pig.tscn")
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
	for pos_vector in all_tile_list:
		var data = island_map.get_cell_tile_data(0, pos_vector)
		var data_type = data.get_custom_data("Type")
		if data_type == "Grassland":
			if pos_vector not in Game.data_layer:
				Game.data_layer[pos_vector] = {
					"type": "grass", 
					"underbrush": 100, 
					"trees": 20,
					"tree_growth_modifier": 0.5, # trees regrow slower on grass
					"ub_growth_modifier": 0.3, # ub regrow slower on grass
					"atlas_coord": Vector2i(0, 0)# store this here for easy access to tile art
					}
		elif data_type == "Forest":
			if pos_vector not in Game.data_layer:
				Game.data_layer[pos_vector] = {
					"type": "forest", 
					"underbrush": 100, 
					"trees": 100,
					"tree_growth_modifier": 1.5, # trees grow faster in woods
					"ub_growth_modifier": 1.3, # ub regrow faster on grass
					"atlas_coord": Vector2i(10, 5) 
					}
		elif data_type == "Desolation":
			if pos_vector not in Game.data_layer:
				Game.data_layer[pos_vector] = {
					"type": "desolation", 
					"underbrush": 0, 
					"trees": 0,
					"tree_growth_modifier": 0, # trees won't regrow here; - 1 to kill of remaining
					"ub_growth_modifier": - 1, # ub won't regrow here; - 1 to kill of remaining
					"atlas_coord": Vector2i(6, 2)
					}

func _process(delta):
	update_herdsize()
	update_map() # this needs to go elsewhere, regrowth is way too fast

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
		#print(Vector2i(entry))
		#print(entry)
		
		# make trees grow according to variables/tile type (modifiers baked in)
		Game.data_layer[entry].trees = snapped(clamp( # clamp to min max values
			(Game.data_layer[entry].trees + (
				Game.tree_growth * # default tree growth amount
				Game.data_layer[entry].tree_growth_modifier * # tile type dependant tree growth modifier
				Game.data_layer[entry].underbrush / 100 - 0.5 # underbrush factor; also ub 80 -> factor 0,3; ub 30 -> factor -0,2; between -0.5 and 0.5
				# this is linear, which is suboptimal, but ok i guess?!
				# Ideally there should be a clever equation that leads to high levels of underbrush leading
				# to default levels of tree growth and increasingly bad levels of tree growth with low underbrush
				# Alternative thought: actually, low levels of underbrush are not a problem, it actually
				# means more space and light for the remaining little trees; so linear might be fine anyway 
				)
			),
			Game.min_forest, Game.max_forest
			), 0.01)
			
		# make underbrush grow according to variables
		Game.data_layer[entry].underbrush = snapped(clamp(
			(Game.data_layer[entry].underbrush + (
				Game.default_underbrush_growth * # default UB growth amount
				Game.data_layer[entry].ub_growth_modifier # do we need more in depth ub regrowth?!
				)
			),
			Game.min_underbrush, Game.max_underbrush
			), 0.01)
			
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
				Game.data_layer[entry].tree_growth_modifier = - 1
				Game.data_layer[entry].ub_growth_modifier = - 1
		
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

				
