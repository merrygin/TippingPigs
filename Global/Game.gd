extends Node

var pigs
var pigHerd

var data_layer = {}

var grass_amount = 0
var forest_amount = 0

func _ready():
	pigs = get_tree().get_nodes_in_group("Pig")
	pigHerd = pigs.size()

	

