extends Node2D
class_name Main
@onready var pig = preload("res://Scenes/Pig.tscn")
@onready var scenic_pigs = $ScenicPigs

func _on_spielen_pressed():
	get_tree().change_scene_to_file("res://Scenes/world.tscn")

func _on_beenden_pressed():
	get_tree().quit()

	
func _ready():
	load_highscores()
	randomize()
	$ScenicPigs.get_child(0).get_node("AnimatedSprite2D").play("Sit")
	
func scenic_pigs_spawn():
	var pigTemp = pig.instantiate()
	var rand_xy = Vector2i(randi_range(300,400), randi_range(200,400))
	pigTemp.position = rand_xy
	scenic_pigs.add_child(pigTemp)
	
func _on_credits_pressed():
	get_tree().change_scene_to_file("res://Scenes/credits.tscn")

func load_highscores():
	var current_highscores = FileAccess.open("res://highscores.data", FileAccess.READ)
	var saved_score = current_highscores.get_var() # get out the scores dict from the file access
	print(saved_score)
	
	var values = saved_score.values() # gets the values stores
	var highest = values.max()
	var name = saved_score.find_key(highest) # gets the corresponding name
	Game.alltime_highscore[name] = highest # store the alltime highscore if needed later
	$Highscore.text = ( # display the name and highscore of the top scorer
		"Highscore: " + name + " - " + str(highest)
	)
