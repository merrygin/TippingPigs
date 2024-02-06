extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text = (
		"Waldflächen: " + str(Game.forest_amount) + " ({0}%)".format([Game.forest_percent]) + 
		"\nGrassflächen: " + str(Game.grass_amount) + " ({0}%)".format([Game.grass_percent])  +
		"\nZerstörtes Land: " + str(Game.deso_amount) + " ({0}%)".format([Game.deso_percent]) +
		"\n\nDurchschnitt:\n   Unterholz - {0}\n   Baumbestand - {1}".format([Game.average_underbrush, Game.average_tree_cover])
	)
	
