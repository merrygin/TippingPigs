class_name Villager
extends CharacterBody2D

const ACCELERATION = 300
const MAX_SPEED = 50
const TOLERANCE = 10 # this will let the pig float around the target point
@onready var island_map = $"../../IslandMap"
@onready var fsm = $FiniteStateMachine as FiniteStateMachine
@onready var idle_state = $FiniteStateMachine/VillagerIdleState as VillagerIdleState
@onready var walk_state = $FiniteStateMachine/VillagerWalkState as VillagerWalkState
@onready var chop_state = $FiniteStateMachine/VillagerChopState as VillagerChopState

func _ready():
	# directing state changes 
	idle_state.need_to_move.connect(fsm.change_state.bind(walk_state))
	idle_state.getting_hungry.connect(fsm.change_state.bind(chop_state))
	walk_state.arrived_at_target.connect(fsm.change_state.bind(idle_state))
	chop_state.chopping_finished.connect(fsm.change_state.bind(idle_state))
	
@export var unit_range = 2
@export var lumber = 10
@export var health = 100.0
@export var trees_cut_per_cut = 50 # @export um die Werte schnell verändern zu können
@export var lumber_per_cut = 5
@export var lumber_consumption_per_tick = 1
@onready var facing = "right"

@onready var start_position = global_position
@onready var target_position = global_position
@onready var world : Node2D = $"../.."

func _process(delta):
	# this shouldn't be done each tick, thats too much.
	if Game.wood > 0:
		Game.wood -= lumber_consumption_per_tick
	
		if health < 100:
			health += 1
		
	else:
		health -= 1
	
	# villagers leave the island if they are annoyed enough
	if health < 0 and Game.pigHerd <= 0:
		queue_free()
		print("This sucks... I'm outta here.")

# return local map position
func get_local_map_position(pos):
	var island_map = $"../../IslandMap"
	var map_position = island_map.local_to_map(pos)
	return map_position 
	
# return local tile data (not really necessary at this point?!)
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

