extends TileMap

# doing this all the time is very inefficient performance wise
# better will be to signal tile changes up and recount tiles in world script 
func _process(delta):
	count_tile_types()
	count_tile_data()

# update the data on environment;
# This is currently only updated once, at the beginning, since nothing changes yet
func _ready():
	get_legal_tiles()

# track data layer data
func count_tile_data():
	var underbrush_amount = 0
	var tree_amount = 0
	var total_entries = len(Game.data_layer)
	for entry in Game.data_layer:
		#print(Game.data_layer[entry])
		underbrush_amount += Game.data_layer[entry].underbrush
		tree_amount += Game.data_layer[entry].trees
	Game.average_underbrush = snapped((underbrush_amount / total_entries), 0.01)
	Game.average_tree_cover = snapped((tree_amount / total_entries), 0.01)
	
	if Game.average_tree_cover <= 66:
		Game.global_threshold = -1
		Game.threshold_level = "yellow"
	elif Game.average_tree_cover <= 50:
		Game.global_threshold = -2
		Game.threshold_level = "red"
	elif Game.average_tree_cover <= 33:
		Game.global_threshold = -4
		Game.threshold_level = "black"

func get_legal_tiles():
	# This loops through every used tile and puts the legal ones in the respective list
	Game.tile_list = get_used_cells_by_id(0)
	var legal_types = ["Grassland", "Forest"]
	
	for tile in Game.tile_list:
		var data := get_cell_tile_data(0, tile)
		var data_type = data.get_custom_data("Type")
		if data_type in legal_types:
			Game.legal_tiles.append(tile)
			
# count forest and grass tiles
func count_tile_types():
	Game.grass_list.clear()
	Game.forest_list.clear()
	Game.deso_list.clear()
	# loop through the tiles and sort them into Grass or Forest
	# this could be done more efficient!
	for tile in Game.legal_tiles:
		# this gets only tiles on the 0 layer of that square/tile
		var data := get_cell_tile_data(0, tile)
		var data_type = data.get_custom_data("Type")
		
		# store the Vectors of all tiles in their respective type category for easy access
		if data_type == "Grassland":
			if tile not in Game.grass_list:
				Game.grass_list.append(tile)
		elif data_type == "Forest":
			if tile not in Game.forest_list:
				Game.forest_list.append(tile)
		elif data_type == "Desolation":
			if tile not in Game.deso_list:
				Game.deso_list.append(tile)
	
	Game.grass_amount = len(Game.grass_list)
	Game.forest_amount = len(Game.forest_list)
	Game.deso_amount = len(Game.deso_list)
	Game.total_amount = Game.grass_amount + Game.forest_amount + Game.deso_amount # this should only be done once
	
	# calculate percentages
	Game.forest_percent = snapped((float(Game.forest_amount) / float(Game.total_amount) * 100), 0.1)
	Game.grass_percent = snapped((float(Game.grass_amount) / float(Game.total_amount) * 100), 0.1)
	Game.deso_percent = snapped((float(Game.deso_amount) / float(Game.total_amount) * 100), 0.1)
	
