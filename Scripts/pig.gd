class_name Piggy
extends CharacterBody2D

const ACCELERATION = 300
const MAX_SPEED = 50
const TOLERANCE = 4.0 # this will let the pig float around the target point

@export var hunger = 50
@export var health = 100
@export var eat_rate = 50

# state handling
@onready var fsm = $FiniteStateMachine as FiniteStateMachine
@onready var walk_state = $FiniteStateMachine/WalkState as WalkState
@onready var eat_state = $FiniteStateMachine/EatState as EatState
@onready var idle_state = $FiniteStateMachine/IdleState as IdleState
@onready var island_map = $"../../IslandMap"
@onready var start_position = global_position
@onready var target_position = global_position

@onready var facing = "right"
@onready var unit_range : int = 5

func _ready():
	# directing state changes 
	idle_state.getting_hungry.connect(fsm.change_state.bind(eat_state))
	idle_state.need_to_move.connect(fsm.change_state.bind(walk_state))
	walk_state.arrived_at_target.connect(fsm.change_state.bind(eat_state))
	eat_state.eating_finished.connect(fsm.change_state.bind(idle_state))


func _process(delta):
	# hunger increases - if hunger is too high, health decreases; if low, health increases
	hunger += 1
	
	if hunger > 100:
		hunger = 100
		health -= 1

	elif hunger <= 10:
		health += 1
	
	if health > 100:
		health = 100
	#print("Hunger: " + str(hunger))

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
