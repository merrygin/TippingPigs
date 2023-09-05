extends Node2D
@onready var pig = preload("res://Scenes/Pig.tscn")
@onready var scenic_pigs = $ScenicPigs

func _on_spielen_pressed():
	get_tree().change_scene_to_file("res://Scenes/world.tscn")


func _on_beenden_pressed():
	get_tree().quit()

func _ready():
	randomize()
	$ScenicPigs.get_child(0).get_node("AnimatedSprite2D").play("Sit")
	
func scenic_pigs_spawn():
	var pigTemp = pig.instantiate()
	var rand_xy = Vector2i(randi_range(300,400), randi_range(200,400))
	pigTemp.position = rand_xy
	scenic_pigs.add_child(pigTemp)
	
