extends Node

var pigs
var pigHerd

var grass_amount = 0
var forest_amount = 0

func _ready():
	pigs = get_tree().get_nodes_in_group("Pig")
	pigHerd = pigs.size()

	

