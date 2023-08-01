extends Node



var ticks = 0

var pigs
var pigHerd

var data_layer = {}

var global_threshold = 0
var total_amount = 0
var forest_amount = 0
var forest_percent = 0.0
var grass_amount = 0
var grass_percent = 0.0
var deso_amount = 0
var deso_percent = 0.0
var average_underbrush = 0 #not used yet
var average_tree_cover = 0 #not used yet

var min_underbrush = 0.0
var max_underbrush = 100.0
var min_forest = 0.0
var max_forest = 100.0

var tree_growth = 1
var default_forest_tree_modifier = 1.5
var default_grass_tree_modifier = 0.5
var default_underbrush_growth = 0.1
var ub_tree_growth_factor = 1
var tree_ub_growth_factor = 1
var surround_modifier = 0

func _ready():
	pigs = get_tree().get_nodes_in_group("Pig")
	pigHerd = pigs.size()

func _process(delta):
	pass
 

# tile types (tt), default properties; for reference
var tt_GRASS = {
		"type": "grass", 
		"underbrush": 20, 
		"trees": 0,
		"tree_growth_modifier": 0.5, # trees regrow slower on grass
		"ub_growth_modifier": 0.3, # ub regrow slower on grass
		"atlas_coord": Vector2i(0, 0)# store this here for easy access to tile art
		}
var tt_FOREST = {
		"type": "forest", 
		"underbrush": 100, 
		"trees": 100,
		"tree_growth_modifier": 1.5, # trees grow faster in woods
		"ub_growth_modifier": 1.3, # ub regrow faster on grass
		"atlas_coord": Vector2i(10, 5) 
		}
var tt_DESOLATION = {
		"type": "desolation", 
		"underbrush": 0, 
		"trees": 0,
		"tree_growth_modifier": 0, # trees won't regrow here
		"ub_growth_modifier": 0, # ub won't regrow here
		"atlas_coord": Vector2i(6, 2)
		}
	
