extends TileMap

# doing this all the time is very inefficient performance wise
# better will be to signal tile changes up and recount tiles in world script 
func _process(delta):
	count_tile_types()

# update the data on environment;
# This is currently only updated once, at the beginning, since nothing changes yet
func _ready():
	#custom_data_test()
	pass
	
# this is just a test if this works
func custom_data_test():
	var tile_data = get_cell_tile_data(0, Vector2i(13, 16))
	var test_data = tile_data.get_custom_data("Type")
	var test_num = tile_data.get_custom_data("Underbrush")
	print("Test data: {0} - Test number: {1}".format([test_data, test_num]))

# count forest and grass tiles
func count_tile_types():
	# get all cells that have a tile
	var tile_list = get_used_cells_by_id(0)
	var grass_list = []
	var forest_list = []
	
	# loop through the tiles and sort them into Grass or Forest
	for tile in tile_list:
		# this gets only tiles on the 0 layer
		var data := get_cell_tile_data(0, tile)
		var data_type = data.get_custom_data("Type")
		if data_type == "Grassland":
			if tile not in grass_list:
				grass_list.append(tile)
		elif data_type == "Forest":
			if tile not in forest_list:
				forest_list.append(tile)
	
	Game.grass_amount = len(grass_list)
	Game.forest_amount = len(forest_list)


