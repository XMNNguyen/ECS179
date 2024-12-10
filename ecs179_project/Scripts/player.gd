class_name Player
extends CharacterBody2D


signal healthChange

const MAX_SPEED = 120

enum {IDLE, MOVE}
var state = IDLE
var on_slope: bool = false

# STATS
@export var maxHeart: float = 8
@export var attack_speed: float = 0.5 # NOTE: attack speed should never be >1.99
@export var attack_range: float = 150
@export var collect_range: float = 75

# WEAPON STATS
# STANDARD WEAPON
@export var standard_bullet_speed: float = 150
@export var standard_bullet_damage: float = 1
@export var standard_attack_cd: float = 1
@export var num_standard_bullets: int = 1

# WAVE WEAPON
@export var wave_bullet_speed: float = 100
@export var wave_bullet_damage: float = 2
@export var wave_attack_cd: float = 4
@export var num_wave_bullets: int = 1

# SHOTGUN WEAPON
@export var shotgun_bullet_speed: float = 150
@export var shotgun_bullet_damage: float = 1
@export var shotgun_attack_cd: float = 3
@export var num_shotgun_bullets: int = 5
@export_range(0, 360) var shotgun_angle: float = 70

# AUDIO
@onready var projectile_sound: AudioStreamPlayer2D = $ProjectileSound

# OTHER
@onready var health: float = maxHeart
@onready var animationTree:AnimationTree = $AnimationTree
@onready var state_machine = animationTree["parameters/playback"]
@onready var tile_map: TileMapController = %TileMap

var wave_bullet = preload("res://Scenes/Attacks/wave_bullet.tscn")
var standard_bullet = preload("res://Scenes/Attacks/standard_bullet.tscn")
var shotgun_bullet = preload("res://Scenes/Attacks/shotgun_bullet.tscn")

var blend_position : Vector2 = Vector2.ZERO
var blend_paths = [
	"parameters/idle/idle_blend/blend_position",
	"parameters/move/move_blend/blend_position"
]
var state_keys = [
	"idle",
	"move"
]

# WEAPON TIMERS
var _standard_weapon_timer: Timer
var _wave_weapon_timer: Timer
var _shotgun_weapon_timer: Timer

var ground_type = "Terrain"

func _ready() -> void:
	signals.collect_soul.connect(on_soul_collect)
	signals.player_take_damage.connect(_on_take_damage)
	
	# set up timers
	_standard_weapon_timer = Timer.new()
	_standard_weapon_timer.one_shot = true
	add_child(_standard_weapon_timer)
	_standard_weapon_timer.start(standard_attack_cd * (2 - attack_speed))
	
	_shotgun_weapon_timer = Timer.new()
	_shotgun_weapon_timer.one_shot = true
	add_child(_shotgun_weapon_timer)
	_shotgun_weapon_timer.start(shotgun_attack_cd * (2 - attack_speed))
	
	_wave_weapon_timer = Timer.new()
	_wave_weapon_timer.one_shot = true
	add_child(_wave_weapon_timer)
	_standard_weapon_timer.start(standard_attack_cd * (2 - attack_speed))


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

	fire()


func on_soul_collect(amount: int) -> void:
	souls_count.souls += amount


func get_tile_type() -> int:
	var tile_position: Vector2i = tile_map.local_to_map(self.position)
	var tile_type: TileData = tile_map.get_cell_tile_data(1, tile_position)
	if tile_type:
		var data = tile_type.get_custom_data(ground_type)
		return data
	else:
		return 0
		
func get_closest_enemy_position() -> Vector2:
	# get all enemies within our world scene
	var enemies_in_scene: Array[Node] = get_tree().get_nodes_in_group("Enemies")
	var closest_enemy_distance: float = 100000
	var closest_enemy_position: Vector2 = Vector2(100000, 100000)

	# iterate through every enemy comparing the distances to get the min distance from the player
	for enemy in enemies_in_scene:
		var enemy_distance: float = global_position.distance_to(enemy.global_position)
		if enemy_distance < closest_enemy_distance:
			closest_enemy_distance = enemy_distance
			closest_enemy_position = enemy.global_position
	
	# return the enemy's position that was the closest to the player
	return closest_enemy_position


# NOTE: make sure to update this function if we add more weapon types
# fires all of the player's weapons
func fire() -> void:
	var closest_enemy_position: Vector2 = get_closest_enemy_position()
	var distance_to_enemy: float = global_position.distance_to(closest_enemy_position)
	if distance_to_enemy <= attack_range:
		# FIRE STANDARD WEAPON
		if _standard_weapon_timer.is_stopped():
			Audio.player_projectile.play()
			fire_standard(closest_enemy_position)
		
		# FIRE SHOTGUN WEAPON
		if _shotgun_weapon_timer.is_stopped():
			fire_shotgun(closest_enemy_position)
		
		# FIRE WAVE WEAPON
		if _wave_weapon_timer.is_stopped() && souls_count.souls >= 100:
			fire_wave(closest_enemy_position)
	

# fires the standard weapon from player
func fire_standard(enemy_position: Vector2) -> void:
	var fire_direction: Vector2 = (enemy_position - global_position).normalized()
	var new_bullet := standard_bullet.instantiate() as StandardBullet
	new_bullet.velocity = fire_direction * standard_bullet_speed
	new_bullet.rotation = fire_direction.angle()
	new_bullet.damage = standard_bullet_damage
	new_bullet.z_index = z_index
	add_child(new_bullet)
	new_bullet.global_position = global_position
	
	_standard_weapon_timer = Timer.new()
	_standard_weapon_timer.one_shot = true
	add_child(_standard_weapon_timer)
	_standard_weapon_timer.start(standard_attack_cd * (2 - attack_speed))


func fire_shotgun(enemy_position: Vector2) -> void:
	var fire_direction: Vector2 = (enemy_position - global_position).normalized()
	
	for i in range(num_shotgun_bullets):
		var new_bullet := shotgun_bullet.instantiate() as ShotgunBullet
		
		# calculate the rotation of this bullet
		# convert the shotgun angle into radians
		var angle_radians = deg_to_rad(shotgun_angle)
		
		# get the current segment of the angle we are currently on
		var angle = angle_radians / num_shotgun_bullets
		
		# for this iteration take the base fire_direction and move the angle based on current segment
		# rotate the angle about angle_radians/2 in order to have the center of our angle be towards the firing direction
		var rotation: float = fire_direction.angle() + (angle * i) - (angle_radians/2)
		new_bullet.velocity = Vector2.RIGHT.rotated(rotation) * shotgun_bullet_speed
		new_bullet.rotation = rotation
		
		new_bullet.damage = shotgun_bullet_damage
		new_bullet.z_index = z_index
		add_child(new_bullet)
		new_bullet.global_position = global_position
	
	_shotgun_weapon_timer = Timer.new()
	_shotgun_weapon_timer.one_shot = true
	add_child(_shotgun_weapon_timer)
	_shotgun_weapon_timer.start(shotgun_attack_cd * (2 - attack_speed))

# fires the wave bullet attack
func fire_wave(enemy_position: Vector2) -> void:
	# directions to fire the wave in
	var fire_directions: Array[Vector2] = [
											Vector2(0.75, 0.75),
											Vector2(-0.75, 0.75),
											Vector2(0.75, -0.75),
											Vector2(-0.75, -0.75),
										]
	# fire 1 wave bullet in each of the specified directions
	for fire_direction in fire_directions:
		var new_bullet := wave_bullet.instantiate() as WaveBullet
		new_bullet.velocity = fire_direction * wave_bullet_speed
		new_bullet.rotation = fire_direction.angle()
		new_bullet.damage = wave_bullet_damage
		new_bullet.z_index = z_index
		add_child(new_bullet)
		new_bullet.global_position = global_position
	 
	_wave_weapon_timer = Timer.new()
	_wave_weapon_timer.one_shot = true
	add_child(_wave_weapon_timer)
	_wave_weapon_timer.start(wave_attack_cd * (2 - attack_speed))


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
	

#func _on_hurt_box_area_entered(area: Area2D) -> void: # When a damaging collision hits the player
	#if area.name == "hitBox": # Change this to the name of the collision that will damage the player
		#health -= 0.5
		#if health < 0: # Making sure that health doesn't go negative
			#health = 0
		#healthChange.emit(health)
		#if health == 0:
			#pass # Actions for player death here
	#if area.name == "hitBox2": # This can be the hit box of a boss doing double damage
		#health -= 2
		#if health < 0: # Making sure that health doesn't go negative
			#health = 0
		#healthChange.emit(health)
		#if health == 0:
			#pass # Actions for player death here


func _on_take_damage(damage : float):
	health -= damage
	if health < 0: # Making sure that health doesn't go negative
		health = 0
	healthChange.emit(health)


func _on_animated_sprite_2d_frame_changed() -> void:
	if $AnimatedSprite2D.animation == "idle": 
		return
	if $AnimatedSprite2D.animation == "move":
		if get_tile_type() == 1:
			if Audio.walk_water.playing:
				return
			else:
				Audio.walk_water.play()
		else:
			if Audio.walk_grass.playing:
				return
			else:
				Audio.walk_grass.play()
		
