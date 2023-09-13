class_name Piggy
extends CharacterBody2D

const ACCELERATION = 300
const MAX_SPEED = 50
const TOLERANCE = 4.0 # this will let the pig float around the target point

enum {
	IDLE,
	WANDER,
	HUNGRY,
	EAT
}

@export var hunger = 50
@export var health = 100
@export var eat_rate = 20
var state = IDLE

# state handling
#@onready var fsm = $FiniteStateMachine as FiniteStateMachine
#@onready var walk_state = $FiniteStateMachine/WalkState as WalkState
#@onready var eat_state = $FiniteStateMachine/EatState as EatState
#@onready var idle_state = $FiniteStateMachine/IdleState as IdleState
@onready var island_map = $"../../IslandMap"
@onready var start_position = global_position
@onready var target_position = global_position
@onready var animated_sprite = $AnimatedSprite2D as AnimatedSprite2D

@onready var facing = "right"
@onready var unit_range : int = 5

func _ready():
	# directing state changes 
	#idle_state.getting_hungry.connect(fsm.change_state.bind(eat_state))
	#idle_state.need_to_move.connect(fsm.change_state.bind(walk_state))
	#walk_state.arrived_at_target.connect(fsm.change_state.bind(idle_state))
	#eat_state.eating_finished.connect(fsm.change_state.bind(idle_state))
	pass

func _process(delta):
	# hunger increases - if hunger is too high, health decreases; if low, health increases
	hunger += 1

	if hunger >= 100:
		hunger = 100
		health -= 1

	elif hunger <= 10:
		health += 1
	
	if health > 100:
		health = 100

	
	update_state()

	#print(state)
	
func _physics_process(delta):
	match state:
		WANDER:
			if facing == "right": # if movement towards right
				get_node("AnimatedSprite2D").play("Move_r")
			elif facing == "left": # if movement towards left
				get_node("AnimatedSprite2D").play("Move_l")
			accelerate_to_point(target_position, ACCELERATION * delta)
			if is_at_target_position():
				decelerate_at_point(target_position, ACCELERATION * delta)
				#print(position, global_position)
				state = IDLE
	move_and_slide()

# return only local map position
func get_local_map_position(pos):
	var island_map = $"../../IslandMap"
	var map_position = island_map.local_to_map(pos)
	return map_position
	
# return local tile data
func get_local_map_tile_data(pos):
	var island_map = $"../../IslandMap"
	var map_position = island_map.local_to_map(pos)
	var tile_data = island_map.get_cell_tile_data(0, Vector2i(map_position))
	#var test_data = tile_data.get_custom_data("Underbrush")
	return tile_data
	
func is_at_target_position(): 
	# Stop moving when at target +/- tolerance -> not super precise targetting
	return (target_position - global_position).length() < TOLERANCE

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

# better target positions
func update_target_pos():
	# this gets a random tile in unit_range; might be performance intensive... range is not strictly
	# necessary imo
	var range_list = []
	# get all tiles that are legal and in range
	for tile in Game.legal_tiles:
		if tile[0] in range(tile[0]-5, tile[0]+5) and tile[1] in range(tile[1]-5, tile[1]+5):
			range_list.append(tile)
	
	# get one random tile off of the range list and convert it to local coordinates
	var random_tile_index = range_list[randi() % range_list.size()]
	var random_legal_tile_center = island_map.map_to_local(random_tile_index)
	
	# define this as new target position
	target_position = random_legal_tile_center
		
	range_list.clear()
	
	if target_position[0] > global_position[0]: # if movement towards right
		facing = "right"
	elif target_position[0] < global_position[0]: # if movement towards left
		facing = "left"
		
# Check state, check if hungry -> if hungry and if no food available, change state to roaming
func update_state():
	match state:
		IDLE:
			# get_node("AnimatedSprite2D").play("Idle")
			
			if hunger > 5:
				state = HUNGRY

		HUNGRY:
			# pull underbrush stats from current tile out of games data layer
			var tile_coords = get_local_map_position(self.position)
			#print("Pig now at {0}".format([tile_coords]))
			var available_underbrush = Game.data_layer[tile_coords]["underbrush"]
			#print("At this tile, {0} underbrush is left".format([available_underbrush]))

			# check if enough underbrush for eating
			if available_underbrush >= 50:
				if facing == "right": # if movement towards right
					animated_sprite.play("Eat_r")

				elif facing == "left": # if movement towards left
					animated_sprite.play("Eat_l")
			
				# this is eating action
				var new_underbrush = available_underbrush - 5
				if new_underbrush <= 0:
					new_underbrush = 0 
					
				# go to data layer and change data
				Game.data_layer[tile_coords]["underbrush"] = new_underbrush
				#print("I ATE")
				hunger = hunger - 1
				#print(Game.data_layer[tile_coords]["underbrush"])
				if hunger <= 0:
					hunger = 0
				
				#print("Pig ate here and now there is {0} underbrush left.".format([Game.data_layer[tile_coords]["underbrush"]]))
				state = IDLE

			else:
				state = WANDER
				update_target_pos()
				#print("Nothing to eat here, will wander.")
				
