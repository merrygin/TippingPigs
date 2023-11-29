extends CharacterBody2D

func _ready():
	get_node("AnimatedSprite2D").play("Sleep")


func _process(delta):
	pass

