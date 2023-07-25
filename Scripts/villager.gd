extends CharacterBody2D

const ACCELERATION = 300
const MAX_SPEED = 50
const TOLERANCE = 10 # this will let the pig float around the target point

func _ready():
	get_node("AnimatedSprite2D").play("Idle")

enum {
	IDLE,
	WANDER,
	HUNGRY,
	EATING
}

@export var lumber = 10
@export var health = 10
@export var trees_cut_per_cut = 50 # @export um die Werte schnell verändern zu können
@export var lumber_per_cut = 5
@export var lumber_consumption_per_tick = 1
var state = IDLE
var wander_timer = 0

@onready var start_position = global_position
@onready var target_position = global_position
@onready var island_map : TileMap = $"../../IslandMap"
@onready var world : Node2D = $"../.."

func _process(delta):
	if lumber > 0:
		lumber -= lumber_consumption_per_tick
		
	else:
		lumber = 0
	update_state()



# return local map position
func get_local_map_position(pos):
	var map_position = island_map.local_to_map(pos)
	return map_position 
# return local tile data (not really necessary at this point?!)
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
			# if IDLE and lumber is getting low, getting hungry
			if lumber < 5:
				state = HUNGRY # hungry for WOOD
				
		HUNGRY:
			get_node("AnimatedSprite2D").play("Idle")
			# pull tree stats from current tile out of games data layer; also only cut trees from forest
			var tile_coords = get_local_map_position(self.position)
			

			if Game.data_layer[tile_coords]["type"] == "forest": 
				var available_trees = Game.data_layer[tile_coords]["trees"]
				# check if enough trees for cutting
				if available_trees >= 20:
					# this is cutting action -> should be own function, probably
					var new_trees = available_trees - trees_cut_per_cut
					Game.data_layer[tile_coords]["trees"] = new_trees # go to data layer and change data
					lumber += lumber_per_cut # convert to lumber!
					if lumber > 10:
						lumber = 10

			else:
				state = WANDER
				wander_timer = 0
				update_target_position()
				#print("Nothing to eat here, will wander.")
				
		WANDER: 		
			# time out for movement if it takes too long; should this be somewhere else?
			wander_timer += 1
			if wander_timer >= 500:
				#print("This is taking too long...")
				update_target_position()
				wander_timer = 0
		
# find a new RAndOM! target to move to
# EITHER make pig reconsider if target pos is unreachable
# OR Make it reconsider if it takes too long
func update_target_position():
	var target_vector = Vector2(randi_range(-100, 100), randi_range(-100, 100))
	target_position = self.position + target_vector
	#print("Sniff sniff... {0} doesn't smell like sea water. Good tidings.".format([target_position]))
	
	# checking if target vec is legal, recalculating till its fine
	while get_local_map_position(target_position) not in Game.data_layer:
		target_vector = Vector2(randi_range(-100, 100), randi_range(-100, 100))
		target_position = self.position + target_vector
		#print("Can't find any acorns in the Pacific. Abort!")
		#if get_local_map_position(target_position) in Game.data_layer:
			#print(target_position)
			#print("{0} smells better. Oink!".format([target_position]))
	

	
func is_at_target_position(): 
	# Stop moving when at target +/- tolerance -> not super precise targetting
	return (target_position - global_position).length() < TOLERANCE

func _physics_process(delta):
	match state:
		WANDER:
			accelerate_to_point(target_position, ACCELERATION * delta)
			wander_timer += 1
			
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

