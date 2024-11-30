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
		blend_position = input_vector

	move_and_slide()
	state_machine.travel(state_keys[state])
	animationTree.set(blend_paths[state], blend_position)
	
	if !on_slope && is_on_slope(z_index):
		on_slope = true
		z_index += 1
	elif !on_slope && is_on_slope(z_index - 1):
		on_slope = true
		z_index -= 1
	else:
		on_slope = false

# helper function to determine if the player is on a slope
func is_on_slope(layer: int) -> bool:
	# get coordianates of the tile player is standing on then get the tile data
	var player_tile_position:Vector2i = tile_map.local_to_map($CollisionShape2D.global_position)
	var tile:Vector2i = tile_map.get_cell_atlas_coords(layer, player_tile_position)
	
	# check if the tile is of type slope and return true if it is
	if tile in tile_map.slopes:
		return true
	
	return false
	
	
