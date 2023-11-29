class_name Villager
extends CharacterBody2D

const ACCELERATION = 300
const MAX_SPEED = 50
const TOLERANCE = 4 # this will let the pig float around the target point

enum {
	IDLE,
	WANDER,
	HUNGRY,
	EAT
}

var state = IDLE
@onready var island_map = $"../../IslandMap"
#@onready var fsm = $FiniteStateMachine as FiniteStateMachine
#@onready var idle_state = $FiniteStateMachine/VillagerIdleState as VillagerIdleState
#@onready var walk_state = $FiniteStateMachine/VillagerWalkState as VillagerWalkState
#@onready var chop_state = $FiniteStateMachine/VillagerChopState as VillagerChopState
@onready var animated_sprite = $AnimatedSprite2D as AnimatedSprite2D

@export var unit_range = 2
@export var lumber = 10
@export var trees_cut_per_cut = 25 # @export um die Werte schnell verändern zu können
@export var lumber_per_cut = 20
@export var lumber_consumption_per_tick = 1
@onready var facing = "right"

@onready var start_position = global_position
@onready var target_position = global_position
@onready var world : Node2D = $"../.."

func _ready():
	# directing state changes 
	#idle_state.need_to_move.connect(fsm.change_state.bind(walk_state))
	#idle_state.getting_hungry.connect(fsm.change_state.bind(chop_state))
	#walk_state.arrived_at_target.connect(fsm.change_state.bind(idle_state))
	#chop_state.chopping_finished.connect(fsm.change_state.bind(idle_state))
	pass
	
func _process(delta):
	# this shouldn't be done each tick, thats too much.
	lumber -= lumber_consumption_per_tick
	#print(lumber)
	# villagers leave the island if they are annoyed enough
	if Game.zufriedenheit <= -100 and Game.pigHerd <= 0:
		queue_free()
		print("This sucks... I'm outta here.")
		
	update_state()

func _physics_process(delta):
	match state:
		WANDER:
			if facing == "right": # if movement towards right
				animated_sprite.play("Move_lr")
				animated_sprite.flip_h = false
			elif facing == "left": # if movement towards left
				animated_sprite.play("Move_lr")
				animated_sprite.flip_h = true
				
			accelerate_to_point(target_position, ACCELERATION * delta)
			if is_at_target_position():
				decelerate_at_point(target_position, ACCELERATION * delta)
				#print(position, global_position)
				state = IDLE
				
	move_and_slide()

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

		
# Check state, check if hungry -> if hungry and if no food available, change state to roaming
func update_state():
	match state:
		IDLE:
			if lumber > 80:
				animated_sprite.play("Idle")
			# if IDLE and getting hungry, change state to hungry
			if lumber <= 100:
				state = HUNGRY

		HUNGRY:
			# pull tree stats from current tile out of games data layer
			var tile_coords = get_local_map_position(self.position)
			var available_trees = Game.data_layer[tile_coords]["trees"]

			# check if enough trees for cutting
			if available_trees >= 50:

				if facing == "right": # if movement towards right
					animated_sprite.play("Chop")
					animated_sprite.flip_h = false
				elif facing == "left": # if movement towards left
					animated_sprite.play("Chop")
					animated_sprite.flip_h = true
				#await get_node("AnimatedSprite2D").animation_looped
				#if animated_sprite.animation_finished:
					#eat()
					# this is eating action -> should be own function, probably
				var new_trees = available_trees - trees_cut_per_cut
				if new_trees <= 0:
					new_trees = 0 
				#print("EAT WOOD")
				lumber += 1

				# go to data layer and change data
				Game.data_layer[tile_coords]["trees"] = new_trees
				#print("Pig ate here and now there is {0} underbrush left.".format([Game.data_layer[tile_coords]["underbrush"]]))
				state = IDLE

			else:
				state = WANDER
				update_target_pos()
				#print("ELSE: WANDER!")

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

func eat():
	print("EATING WOOOOOD")
