extends CharacterBody2D

const MAX_SPEED = 120

enum {IDLE, MOVE}
var state = IDLE
var on_slope: bool = false

@onready var animationTree:AnimationTree = $AnimationTree
@onready var state_machine = animationTree["parameters/playback"]
@onready var tile_map: TileMapController = %TileMap



var blend_position : Vector2 = Vector2.ZERO
var blend_paths = [
	"parameters/idle/idle_blend/blend_position",
	"parameters/move/move_blend/blend_position"
]
var state_keys = [
	"idle",
	"move"
]

func _physics_process(delta):
	var input_vector = Input.get_vector("left", "right", "up", "down")
	
	if input_vector == Vector2.ZERO:
		state = IDLE
		velocity = Vector2.ZERO
	else:
		state = MOVE
		velocity = input_vector.normalized() * MAX_SPEED
		
		# if our player is moving on a slope, adjust velocity accordingly
		if is_on_slope():
			on_slope = true
			adjust_z_index()
			move_on_slope(input_vector.normalized())
		elif on_slope:
			on_slope = false
			adjust_z_index()
			
		blend_position = input_vector

	move_and_slide()
	state_machine.travel(state_keys[state])
	animationTree.set(blend_paths[state], blend_position)
	

# helper function to adjust the z_index depending on what layer the player is supposed to be on
func adjust_z_index() -> void:
	# get coordianates of the tile player is standing on then get the tile data
	var player_tile_position:Vector2i = tile_map.local_to_map($Head.global_position - Vector2(0, 16))
	var new_z_index:int = 0
	
	for i in range(tile_map.layers.keys().size()):
		if (tile_map.get_cell_source_id(i, player_tile_position) != -1 &&
			tile_map.get_cell_atlas_coords(i, player_tile_position) not in tile_map.other):
			new_z_index += 1
		else:
			break
	if z_index != new_z_index:
		signals.entered_new_layer.emit(max(new_z_index, 1), z_index)
	z_index = max(new_z_index, 1)

# helper function to check if player is on a slope
func is_on_slope() -> bool:
	# get coordianates of the tile player is standing on then get the tile data
	var player_tile_position:Vector2i = tile_map.local_to_map($Head.global_position - Vector2(0, 16))
	
	return (tile_map.get_cell_atlas_coords(z_index, player_tile_position) in tile_map.slopes ||
			tile_map.get_cell_atlas_coords(z_index - 1, player_tile_position) in tile_map.slopes)
			

# add movement bias based on direction the player is moving in
func move_on_slope(input_vector : Vector2):
	var slow_scaling: float = 0.80
	var horizontal_bias:float = 40
	var diagonal_bias:float = 25
	
	# get the tile position of the slope we are on
	var player_tile_position = tile_map.local_to_map($Head.global_position)
	
	# check the slope type and then adjust player velocity accordingly
	velocity *= slow_scaling
	
	# UP RIGHT
	if tile_map.get_cell_atlas_coords(z_index - 1, player_tile_position) in tile_map.up_right_slopes:
		# add a y-bias based on input direction
		if input_vector.x == 1:
			velocity.y -= diagonal_bias 
		elif input_vector.x == -1:
			velocity.y += diagonal_bias
	
	# RIGHT
	elif tile_map.get_cell_atlas_coords(z_index - 1, player_tile_position) in tile_map.right_slopes:
		# add a y-bias based on input direction
		if input_vector.x == -1:
			velocity.y += horizontal_bias
		elif input_vector.x == 1:
			velocity.y -= horizontal_bias
	
	# DOWN RIGHT		
	elif tile_map.get_cell_atlas_coords(z_index - 1, player_tile_position) in tile_map.down_right_slopes:
		# add a y-bias based on input direction
		if input_vector.x == 1:
			velocity.y -= diagonal_bias
		elif input_vector.x == -1:
			velocity.y += diagonal_bias

	# DOWN LEFT	
	elif tile_map.get_cell_atlas_coords(z_index - 1, player_tile_position) in tile_map.down_left_slopes:
		# add a y-bias based on input direction
		if input_vector.x == -1:
			velocity.y -= diagonal_bias
		elif input_vector.x == 1:
			velocity.y += diagonal_bias
	
	# LEFT
	elif tile_map.get_cell_atlas_coords(z_index - 1, player_tile_position) in tile_map.left_slopes:
		# add a y-bias based on input direction
		if input_vector.x == 1:
			velocity.y += horizontal_bias
		elif input_vector.x == -1:
			velocity.y -= horizontal_bias
	
	# UP LEFT
	elif tile_map.get_cell_atlas_coords(z_index - 1, player_tile_position) in tile_map.up_left_slopes:
		# add a y-bias based on input direction
		if input_vector.x == -1:
			velocity.y -= diagonal_bias
		elif input_vector.x == 1:
			velocity.y += diagonal_bias
	
	
	
