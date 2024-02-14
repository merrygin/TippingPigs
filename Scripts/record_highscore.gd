extends Panel

var fired : bool = false
var highscore_string = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	get_scores()
	
func get_scores():
	var current_highscores = FileAccess.open("res://highscores.data", FileAccess.READ)
	var data = current_highscores.get_var()
	var all_values = data.values()# gets all the values stored as array
	all_values.sort_custom(func(a,b): return a > b) # sort the array descending
	all_values.slice(0, 10)
	var list_pos = 1
	highscore_string = ""
	for score in all_values:
		var player = data.find_key(score) # gets the corresponding name
		var next_score = str(list_pos) + ". " + str(player) + ": " + str(score) + "\n"
		highscore_string = highscore_string + next_score # append the next name + score
		list_pos += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$ColorRect/All_Highscores_label.text = (
		"Dein Score: " + str(Game.zufriedenheit) +
		"\nHighscores: " + "\n   " + str(highscore_string)
	)


func _on_line_edit_text_submitted(new_text):
	var current_highscores = FileAccess.open("res://highscores.data", FileAccess.READ)
	var data = current_highscores.get_var()
	data[new_text] = Game.current_highscore
	var file = FileAccess.open("res://highscores.data", FileAccess.READ_WRITE)
	file.store_var(data)
	file.close()
	get_scores()
	
func _on_button_pressed():
	#get_tree().unload_current_scene()
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
