class_name Enemy
extends CharacterBody2D

# STATS
var level: float = 1
var max_health: float = 100
var defense: float = 10
var base_damage: float = 10
var base_speed: float = 10
var base_atk_speed: float = 10
var target: Player
var aggro_range: float = 30 

var _current_health: float = max_health
var _aggro: bool = false

@onready var tile_map: TileMapController = $"/root/World/TileMap"


# TODO: figure out how we will calculate our damage
func calculate_damage() -> float:
	return base_damage


# function that tries to free our enemy instance once health is depleted
func die() -> void:
	if _current_health <= 0:
		print("DEAD")
		queue_free()


# helper function to adjust the z_index depending on what layer the player is supposed to be on
func adjust_z_index(position: Vector2) -> void:
	# get coordianates of the tile player is standing on then get the tile data
	var enemy_tile_position:Vector2i = tile_map.local_to_map(position - Vector2(0, 16))
	var new_z_index:int = 0
	
	for i in range(tile_map.layers.keys().size()):
		if (tile_map.get_cell_source_id(i, enemy_tile_position) != -1 &&
			tile_map.get_cell_atlas_coords(i, enemy_tile_position) not in tile_map.other):
			new_z_index += 1
		else:
			break
			
	z_index = max(new_z_index, 1)


# helper function to check if enemy is on a slope
func is_on_slope(position: Vector2) -> bool:
	# get coordianates of the tile player is standing on then get the tile data
	var enemy_tile_position:Vector2i = tile_map.local_to_map(position - Vector2(0, 16))
	
	return (tile_map.get_cell_atlas_coords(z_index, enemy_tile_position) in tile_map.slopes ||
			tile_map.get_cell_atlas_coords(z_index - 1, enemy_tile_position) in tile_map.slopes)
			

# add movement bias based on direction the enemy is moving in
func move_on_slope(position: Vector2, input_vector : Vector2):
	var slow_scaling: float = 0.80
	var horizontal_bias:float = 40
	var diagonal_bias:float = 25
	
	# get the tile position of the slope we are on
	var enemy_tile_position = tile_map.local_to_map(position)
	
	# check the slope type and then adjust player velocity accordingly
	velocity *= slow_scaling
	
	# UP RIGHT
	if tile_map.get_cell_atlas_coords(z_index - 1, enemy_tile_position) in tile_map.up_right_slopes:
		# add a y-bias based on input direction
		if input_vector.x < 0:
			velocity.y -= diagonal_bias 
		elif input_vector.x < 0:
			velocity.y += diagonal_bias
	
	# RIGHT
	elif tile_map.get_cell_atlas_coords(z_index - 1, enemy_tile_position) in tile_map.right_slopes:
		# add a y-bias based on input direction
		if input_vector.x < 0:
			velocity.y += horizontal_bias
		elif input_vector.x > 0:
			velocity.y -= horizontal_bias
	
	# DOWN RIGHT		
	elif tile_map.get_cell_atlas_coords(z_index - 1, enemy_tile_position) in tile_map.down_right_slopes:
		# add a y-bias based on input direction
		if input_vector.x > 0:
			velocity.y -= diagonal_bias
		elif input_vector.x < 10:
			velocity.y += diagonal_bias

	# DOWN LEFT	
	elif tile_map.get_cell_atlas_coords(z_index - 1, enemy_tile_position) in tile_map.down_left_slopes:
		# add a y-bias based on input direction
		if input_vector.x < 0:
			velocity.y -= diagonal_bias
		elif input_vector.x > 0:
			velocity.y += diagonal_bias
	
	# LEFT
	elif tile_map.get_cell_atlas_coords(z_index - 1, enemy_tile_position) in tile_map.left_slopes:
		# add a y-bias based on input direction
		if input_vector.x > 0:
			velocity.y += horizontal_bias
		elif input_vector.x < 0:
			velocity.y -= horizontal_bias
	
	# UP LEFT
	elif tile_map.get_cell_atlas_coords(z_index - 1, enemy_tile_position) in tile_map.up_left_slopes:
		# add a y-bias based on input direction
		if input_vector.x < 0:
			velocity.y -= diagonal_bias
		elif input_vector.x > 0:
			velocity.y += diagonal_bias
