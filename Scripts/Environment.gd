extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text = (
		"Waldflächen: " + str(Game.forest_amount) + " ({0}%)".format([Game.forest_percent]) + 
		"  |   Grassflächen: " + str(Game.grass_amount) + " ({0}%)".format([Game.grass_percent])  +
		"  |   Zerstörtes Land: " + str(Game.deso_amount) + " ({0}%)".format([Game.deso_percent]) +
		"  |   Durchschnitt: Unterholz - {0} Baumbestand - {1}".format([Game.average_underbrush, Game.average_tree_cover])
	)
	
