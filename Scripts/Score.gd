extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# just a simple placeholder calculation; need to adjust which is more important
	# this should also tick up with a timer, otherwise it gets very frantic
	# Also it should be transparent where the points come from, so ideally a little tween of
	# the plusses and minuses that are briefly floating from the counter
	text = (
		"Zufriedenheit-Score: " + str(Game.zufriedenheit) +
		" | " + "Gesamthighscore: " + str(Game.alltime_highscore)
	)

