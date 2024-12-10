class_name Enemy
extends CharacterBody2D


var soul_scene: PackedScene = preload("res://Scenes/Soul_drop.tscn")

# STATS
var level: float = 1
var max_health: float = 2
var base_damage: float = 0.5
var base_speed: float = 10
var aggro_range: float = 30 
var attack_range: float = 30
var soul_amount: float = 1

var target: Player

var _current_health: float = max_health
var _aggro: bool = false

@onready var tile_map: TileMapController = $"/root/World/TileMap"


# assign stat points based on level
func assign_stats() -> void:
	var stat_num: int
	for i in range(level):
		# get the stat to upgrade
		stat_num = randi_range(0, 2)
		
		# upgrade the corresponding stat
		match stat_num:
			0:
				max_health += 1
				_current_health = max_health
			1:
				base_damage += 0.5
			2: 
				base_speed += 5

	# 1 extra soul dropped per level
	soul_amount += level


func _on_take_damage(damage: int) -> void:
	_current_health -= damage
	die()


# function that tries to free our enemy instance once health is depleted
func die() -> void:
	if _current_health <= 0:
		var soul_instance := soul_scene.instantiate() as SoulDrop
		soul_instance.soul_amount = soul_amount
		$"/root/World".add_child(soul_instance)
		soul_instance.global_position = global_position
		queue_free()
		#if type == "CHICKEN": # Calculates the amount of souls the enemy drops
			#souls_count.souls += 2
			#print(souls_count.souls)
		#if type == "SPROUT":
			#souls_count.souls += 10
			#print(souls_count.souls)


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
func move_on_slope(position: Vector2, input_vector : Vector2, horizontal_bias: float, diagonal_bias:float):
	var slow_scaling: float = 0.80
	
	# get the tile position of the slope we are on
	var enemy_tile_position = tile_map.local_to_map(position)
	
	# check the slope type and then adjust player velocity accordingly
	velocity *= slow_scaling
	
	# UP RIGHT
	if tile_map.get_cell_atlas_coords(z_index - 1, enemy_tile_position) in tile_map.up_right_slopes:
		# add a y-bias based on input direction
		if input_vector.x > 0:
			velocity.y -= diagonal_bias 
		elif input_vector.x < 0:
			velocity.y += diagonal_bias
	
	# RIGHT
	elif tile_map.get_cell_atlas_coords(z_index - 1, enemy_tile_position) in tile_map.right_slopes:
		# add a y-bias based on input direction
		if input_vector.x > 0:
			velocity.y += horizontal_bias
		elif input_vector.x < 0:
			velocity.y -= horizontal_bias
	
	# DOWN RIGHT		
	elif tile_map.get_cell_atlas_coords(z_index - 1, enemy_tile_position) in tile_map.down_right_slopes:
		# add a y-bias based on input direction
		if input_vector.x > 0:
			velocity.y -= diagonal_bias
		elif input_vector.x < 0:
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
