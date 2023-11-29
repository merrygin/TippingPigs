extends Button

var default_text = "Notfall-Festschmaus"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# some kind of cooldown display... but this should only be if timer actually started
	#text = default_text + " (" + str(int($feast_cooldown.time_left + 1)) + "s)"
	pass
