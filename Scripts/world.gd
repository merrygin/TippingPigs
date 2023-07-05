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
	var data_layer = {}
	for pos_vector in all_tile_list:
		var data = island_map.get_cell_tile_data(0, pos_vector)
		var data_type = data.get_custom_data("Type")
		if data_type == "Grassland":
			if pos_vector not in data_layer:
				data_layer[pos_vector] = {
					"type": "grass", 
					"underbrush": 20, 
					"trees": 0,
					"atlas_coord": Vector2i(0, 0)# store this here for easy access to tile art
					}
		elif data_type == "Forest":
			if pos_vector not in data_layer:
				data_layer[pos_vector] = {
					"type": "forest", 
					"underbrush": 100, 
					"trees": 100,
					"atlas_coord": Vector2i(0, 0) 
					}
	
	
	

func _process(delta):
	update_herdsize()

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
	# here I want to build a small little function to display the tile
	# data that Im hovering over, to check sanity of pig behavior/cell changes
	pass
