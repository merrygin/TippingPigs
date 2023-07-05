extends Control

var hunger = get_node("..").health

func _process(delta):
	set_tooltip_text("Current hunger: " + str(hunger))
