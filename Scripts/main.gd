extends Node2D

func _on_spielen_pressed():
	get_tree().change_scene_to_file("res://Scenes/world.tscn")


func _on_beenden_pressed():
	get_tree().quit()
