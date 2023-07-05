extends CharacterBody2D

const ACCELERATION = 300
const MAX_SPEED = 50
const TOLERANCE = 4.0 # this will let the pig float around the target point

func _ready():
	get_node("AnimatedSprite2D").play("Idle")

enum {
	IDLE,
	WANDER,
	HUNGRY,
	EATING
}

@export var hunger = 0
@export var health = 10
var state = IDLE

@onready var stats = $Stats
@onready var start_position = global_position
@onready var target_position = global_position
@onready var island_map : TileMap = $"../../IslandMap"
@onready var world : Node2D = $"../.."


func _process(delta):
	hunger == 10
	
	update_state()


# return only local map position
func get_local_map_position(pos):
	var map_position = island_map.local_to_map(pos)

	return map_position 

# return local tile data
func get_local_map_tile_data(pos):
	var map_position = island_map.local_to_map(pos)
	var tile_data = island_map.get_cell_tile_data(0, Vector2i(map_position))
	#var test_data = tile_data.get_custom_data("Underbrush")
	return tile_data
	
	

# Check state, check if hungry -> if hungry and if no food available, change state to roaming
func update_state():
	match state:
		IDLE:
			get_node("AnimatedSprite2D").play("Idle")
			# if IDLE and getting hungry, change state to hungry
			if hunger > 5:
				state = HUNGRY
				print("Pig got hungry: {0}.".format([self.hunger]))
		HUNGRY:
			get_node("AnimatedSprite2D").play("Idle")
			# pull underbrush stats from current tile out of games data layer
			var tile_coords = get_local_map_position(self.position)
			print("Pig now at {0}".format([tile_coords]))
			var available_underbrush = Game.data_layer[tile_coords]["underbrush"]
			print("At this tile, {0} underbrush is left".format([available_underbrush]))
			
			# check if enough underbrush for eating
			if available_underbrush >= 10:
				# this is eating action -> should be own function, probably
				var new_underbrush = available_underbrush - 5
				# go to data layer and change data
				Game.data_layer[tile_coords]["underbrush"] = new_underbrush
				print("Pig ate here and now there is {0} underbrush left.".format([Game.data_layer[tile_coords]["underbrush"]]))
				
				if new_underbrush < 10:
					# here comes the tile conversion algo
					# should also be its own func probably handled in another script
					Game.data_layer[tile_coords]["type"] = "forest"
					Game.data_layer[tile_coords]["atlas_coord"] = Vector2i(0, 0)
					Game.data_layer[tile_coords]["forest"] = 0
					island_map.set_cell(0, tile_coords, 3, Vector2i(0, 0))
					print("The Forest degraded!")
			
				state = IDLE
			else:
				state = WANDER
				update_target_position()
				print("Nothing to eat here, will wander.")

	# do I have to say something about wander too?! its only used for moving,
	# so Id like to have it in the physics function (or do I?)
	
	
# find a new RAndOM! target to move to
func update_target_position():
	var target_vector = Vector2(randi_range(-200, 200), randi_range(-200, 200))
	target_position = start_position + target_vector
		
func is_at_target_position(): 
	# Stop moving when at target +/- tolerance -> not super precise targetting
	return (target_position - global_position).length() < TOLERANCE

func _physics_process(delta):
	match state:
		WANDER:
			accelerate_to_point(target_position, ACCELERATION * delta)

			if is_at_target_position():
				decelerate_at_point(target_position, ACCELERATION * delta)
				#print(position, global_position)
				state = IDLE

	move_and_slide()

func accelerate_to_point(point, acceleration_scalar):
	var direction = (point - global_position).normalized()
	var acceleration_vector = direction * acceleration_scalar
	accelerate(acceleration_vector)

func accelerate(acceleration_vector):
	velocity += acceleration_vector
	velocity = velocity.limit_length(MAX_SPEED)

# deceleration to 0 or very low value to tweak floating around target point
func decelerate_at_point(point, acceleration_scalar):
	var direction = (point - global_position).normalized()
	var acceleration_vector = direction * acceleration_scalar
	velocity -= acceleration_vector
	velocity = velocity.limit_length(0) # makes pig float slightly at target pos

