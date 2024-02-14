extends Node

# recorded top 10 highscores to be displayed in main menue (are recorded each time a player 
# successfully finishes the game)
var highscores = {} 

var ticks = 0

var pigs
var pigHerd

var villagers
var villager_count

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
@export var max_pigs : int = 300

var tree_growth = 1
var default_forest_tree_modifier = 1.5
var default_grass_tree_modifier = 0.5
var default_underbrush_growth = 0.1
var ub_tree_growth_factor = 1
var tree_ub_growth_factor = 1
var surround_modifier = 0

var wood : int = 0
var zufriedenheit : int = 0
var current_highscore = 0
var alltime_highscore = {}
var threshold_level = "green"

var tile_list = []
var legal_tiles = []
var grass_list = []
var forest_list = []
var deso_list = []

func _ready():
	pigs = get_tree().get_nodes_in_group("Pig")
	pigHerd = pigs.size()
	villagers = get_tree().get_nodes_in_group("villagers_group")
	villager_count = villagers.size()
	check_highscores()
	
func _process(delta):
	pass
	
func check_highscores():
	# check if highscore storage already initialized, if not, make it so
	print("CHECK IN PROG")
	if FileAccess.file_exists("res://highscores.data") == false:
		print("FALSSEEE")
		var file = FileAccess.open("res://highscores.data", FileAccess.WRITE)
		var score_record = {"BradleyPowerPig":1000}
		file.store_var(score_record)
		file.close()
		if FileAccess.file_exists("res://highscores.data") == true:
			print("NOW TRUUUU")
			
			
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
	
