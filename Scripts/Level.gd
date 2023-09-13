extends Node2D

@onready var island_map = $IslandMap


#@onready var tile_tracker = $GUI/HBoxContainer/MarginContainer/graphPanel/graphs
@onready var tile_tracker = $GraphPanel/graphs
@onready var forest_plot: Graph2D.PlotItem = tile_tracker.get_child(0).add_plot_item("Forest Plot", Color.GREEN, 1.0)
@onready var grass_plot: Graph2D.PlotItem = tile_tracker.get_child(0).add_plot_item("Grass Plot", Color.YELLOW, 1.0)
@onready var deso_plot: Graph2D.PlotItem = tile_tracker.get_child(0).add_plot_item("Desolation Plot", Color.RED, 1.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(Game.wood)
	update_herdsize()
	update_map() # this needs to go elsewhere, regrowth is way too fast

	Game.ticks += 1 #advance game ticks

	# adjusting the x axis if game runs longer
	if Game.ticks >= tile_tracker.get_child(0).x_max - 500:
		tile_tracker.get_child(0).x_max += 500
	
	forest_plot.add_point(Vector2(Game.ticks, Game.forest_amount))
	grass_plot.add_point(Vector2(Game.ticks, Game.grass_amount))
	deso_plot.add_point(Vector2(Game.ticks, Game.deso_amount))
	

# update the herdsizes etc. to be displayed
func update_herdsize():
	Game.pigs = get_tree().get_nodes_in_group("pigs_group")
	Game.pigHerd = Game.pigs.size()
	Game.villagers = get_tree().get_nodes_in_group("villagers_group")
	Game.villager_count = Game.villagers.size()
	
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

		# define 3 thresholds of tree amount that influences underbrush growth
		# this could be done more smoothly... 
		if Game.data_layer[entry].trees >= 67: # good growth if many trees
			Game.data_layer[entry].tree_ub_growth_factor = 1
		elif Game.data_layer[entry].trees >= 34: #  growth if some trees
			Game.data_layer[entry].tree_ub_growth_factor = 0
		elif Game.data_layer[entry].trees <= 33: # sharp decline if not enough trees
			Game.data_layer[entry].tree_ub_growth_factor = - 2
					
		# make trees grow according to variables (growth factor and surrounding tiles)

		var new_trees = clamp(
			Game.data_layer[entry].trees +
			Game.data_layer[entry].ub_tree_growth_factor + 
			Game.data_layer[entry].surround_modifier +
			Game.global_threshold,
			Game.min_forest, Game.max_forest
		)
		Game.data_layer[entry].trees = new_trees
		#print(Game.data_layer[entry].trees)
		
		# make underbrush grow according to variables (growth factor and surrounding tiles)
		var new_underbrush = clamp(
			Game.data_layer[entry].underbrush + 
			Game.data_layer[entry].tree_ub_growth_factor +
			Game.data_layer[entry].surround_modifier +
			Game.global_threshold, 
			Game.min_underbrush, Game.max_underbrush)
		Game.data_layer[entry].underbrush = new_underbrush
		#print(Game.data_layer[entry].underbrush)
		
		
		# the following need to be converted into default values....
		if Game.data_layer[entry].type == "forest":
			if Game.data_layer[entry].trees <= 66:
				"""If not enough trees -> this tile is now grassland"""
				Game.data_layer[entry].type = "grass"
				island_map.set_cell(0, Vector2i(entry), 3, Vector2i(0, 0))
				Game.data_layer[entry].atlas_coord = Vector2i(0, 0)
			
			elif Game.data_layer[entry].trees <= 1:
				"""If barely any trees -> this tile is now desolation"""
				island_map.set_cell(0, Vector2i(entry), 3, Vector2i(6, 2))
				Game.data_layer[entry].type = "desolation"
				Game.data_layer[entry].atlas_coord = Vector2i(6, 2)
		
		elif Game.data_layer[entry].type == "grass":
			if Game.data_layer[entry].trees >= 67:
				"""If enough trees regrew -> this tile is now forest"""
				Game.data_layer[entry].type = "forest"
				island_map.set_cell(0, Vector2i(entry), 3, Vector2i(10, 5))
				Game.data_layer[entry].atlas_coord = Vector2i(10, 5)

			elif Game.data_layer[entry].trees <= 1:
				"""If barely any trees -> this tile is now desolation"""
				island_map.set_cell(0, Vector2i(entry), 3, Vector2i(6, 2))
				Game.data_layer[entry].type = "desolation"
				Game.data_layer[entry].atlas_coord = Vector2i(6, 2)


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

	if deso_count >= 2: # if on 2 or more sides desolation -> trees start dying
		local_tile.surround_modifier = - 0.5
		#print(deso_count)
	elif deso_count >= 3: # if on 4 or more sides desolation -> trees start dying
		local_tile.surround_modifier = - 2
		#print(deso_count)
	elif deso_count >= 4: # if on 6 or more sides desolation -> trees start dying
		local_tile.surround_modifier = - 8
		#print(deso_count)

