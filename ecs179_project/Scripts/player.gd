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
@export var wave_bullet_damage: float = 4
@export var wave_attack_cd: float = 3
@export var num_wave_bullets: int = 1

# SHOTGUN WEAPON
@export var shotgun_bullet_speed: float = 150
@export var shotgun_bullet_damage: float = 1
@export var shotgun_attack_cd: float = 3
@export var num_shotgun_bullets: int = 5
@export_range(0, 360) var shotgun_angle: float = 70

# SCATTER WEAPON
@export var scatter_bullet_speed: float = 150
@export var scatter_bullet_damage: float = 2
@export var scatter_attack_cd: float = 3
@export var num_scatter_bullets: int = 20

# CHAIN WEAPON
@export var chain_bullet_speed: float = 100
@export var chain_bullet_damage: float = 2
@export var chain_attack_cd: float = 2
@export var num_chain_bounces: int = 10

# SCENES
var wave_bullet: PackedScene = preload("res://Scenes/Attacks/wave_bullet.tscn")
var standard_bullet: PackedScene = preload("res://Scenes/Attacks/standard_bullet.tscn")
var shotgun_bullet: PackedScene = preload("res://Scenes/Attacks/shotgun_bullet.tscn")
var scatter_bullet: PackedScene = preload("res://Scenes/Attacks/scatter_bullet.tscn")
var chain_bullet: PackedScene = preload("res://Scenes/Attacks/chain_bullet.tscn")
var blood_particles: PackedScene = preload("res://Scenes/blood_particles.tscn")
var smoke_particles: PackedScene = preload("res://Scenes/smoke_particles.tscn")
var energy_particles: PackedScene = preload("res://Scenes/energy_particles.tscn")

var blend_position : Vector2 = Vector2.ZERO
var blend_paths = [
	"parameters/idle/idle_blend/blend_position",
	"parameters/move/move_blend/blend_position"
]
var state_keys = [
	"idle",
	"move"
]

# TIMERS
var _standard_weapon_timer: Timer
var _wave_weapon_timer: Timer
var _shotgun_weapon_timer: Timer
var _scatter_weapon_timer: Timer
var _chain_weapon_timer: Timer
var _cc_timer: Timer
var _pause_timer: Timer

var _dialogue = false
var ground_type = "Terrain"

# AUDIO
@onready var projectile_sound: AudioStreamPlayer2D = $ProjectileSound

# OTHER
@onready var health: float = maxHeart
@onready var animationTree:AnimationTree = $AnimationTree
@onready var state_machine = animationTree["parameters/playback"]
@onready var tile_map: TileMapController = %TileMap
@onready var actionable_finder: Area2D = $ActionableFinder


func _ready() -> void:
	# connect signals and set stun particles to off
	signals.collect_soul.connect(on_soul_collect)
	signals.player_take_damage.connect(_on_take_damage)
	signals.player_stunned.connect(_on_player_stun)
	signals.boss_died.connect(_on_boss_death)
	$Stun_Particles.play("idle")
	
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

	_scatter_weapon_timer = Timer.new()
	_scatter_weapon_timer.one_shot = true
	add_child(_scatter_weapon_timer)
	_scatter_weapon_timer.start(standard_attack_cd * (2 - attack_speed))
	
	_chain_weapon_timer = Timer.new()
	_chain_weapon_timer.one_shot = true
	add_child(_chain_weapon_timer)
	_chain_weapon_timer.start(chain_attack_cd * (2 - attack_speed))


func _physics_process(delta):
	# get the controller input
	var input_vector = Input.get_vector("left", "right", "up", "down")
	
	# set state to IDLE or MOVE based on if we are moving or not
	if input_vector == Vector2.ZERO:
		state = IDLE
		velocity = Vector2.ZERO
	elif _cc_timer == null || _cc_timer.is_stopped():
		state = MOVE
		velocity = input_vector.normalized() * MAX_SPEED
		
		# if our player is moving on a slope, adjust velocity accordingly
		if is_on_slope():
			on_slope = true
			adjust_z_index()
			move_on_slope(input_vector.normalized())
		else:
			on_slope = false
			adjust_z_index()
		
		blend_position = input_vector
	
	if _cc_timer == null || _cc_timer.is_stopped():
		$Stun_Particles.visible = false
	
	move_and_slide()
	state_machine.travel(state_keys[state])
	animationTree.set(blend_paths[state], blend_position)
	
	# fire player weapons
	fire()
	
	# if we have interacted with an interactable, initiate cutscene
	if Input.is_action_just_pressed("ui_accept") and _dialogue == false:
		var actionables = actionable_finder.get_overlapping_areas()
		if actionables.size() > 0:
			_dialogue = true
			actionables[0].action()
			return


func on_soul_collect(amount: int) -> void:
	souls_count.souls += amount


func get_tile_type() -> int:
	# get tile position and type
	var tile_position: Vector2i = tile_map.local_to_map(self.position)
	var tile_type: TileData = tile_map.get_cell_tile_data(1, tile_position)
	
	# return the tile type
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
	if distance_to_enemy <= attack_range && (_cc_timer == null || _cc_timer.is_stopped()):
		# FIRE STANDARD WEAPON
		if _standard_weapon_timer.is_stopped():
			Audio.player_projectile.play()
			fire_standard(closest_enemy_position)
			Input.action_press("spell_1")
			Input.action_release("spell_1")
			
		# FIRE SHOTGUN WEAPON
		if _shotgun_weapon_timer.is_stopped() && souls_count.souls >= 100:
			Audio.player_projectile.play()
			fire_shotgun(closest_enemy_position)
			Input.action_press("spell_2")
			Input.action_release("spell_2")
			
		# FIRE WAVE WEAPON
		if _wave_weapon_timer.is_stopped() && souls_count.souls >= 250:
			Audio.player_projectile.play()
			fire_wave(closest_enemy_position)
			Input.action_press("spell_3")
			Input.action_release("spell_3")
			
		# FIRE SCATTER WEAPON
		if _scatter_weapon_timer.is_stopped() && souls_count.souls >= 650:
			Audio.player_projectile.play()
			fire_scatter(closest_enemy_position)

		# FIRE CHAIN WEAPON
		if _chain_weapon_timer.is_stopped() && souls_count.souls >= 1000:
			Audio.player_projectile.play()
			fire_chain(closest_enemy_position)
			Input.action_press("spell_4")


# fires the standard weapon from player
func fire_standard(enemy_position: Vector2) -> void:
	# get the normalize direction vector towards the enemy
	var fire_direction: Vector2 = (enemy_position - global_position).normalized()
	
	# initialize bullet and stats
	var new_bullet := standard_bullet.instantiate() as StandardBullet
	new_bullet.velocity = fire_direction * standard_bullet_speed
	new_bullet.rotation = fire_direction.angle()
	new_bullet.damage = standard_bullet_damage
	new_bullet.z_index = z_index
	add_child(new_bullet)
	new_bullet.global_position = global_position
	
	# set cooldown
	_standard_weapon_timer = Timer.new()
	_standard_weapon_timer.one_shot = true
	add_child(_standard_weapon_timer)
	_standard_weapon_timer.start(standard_attack_cd * (2 - attack_speed))


# fires the shotgun weapon from player
func fire_shotgun(enemy_position: Vector2) -> void:
	# get the normalized direction vector towards the enemy
	var fire_direction: Vector2 = (enemy_position - global_position).normalized()
	
	# iterate through the bullets in our angle and adjust their firing direction accordingly
	for i in range(num_shotgun_bullets):
		var new_bullet := shotgun_bullet.instantiate() as ShotgunBullet
		
		# calculate the fire angle of this bullet
		# convert the shotgun angle into radians
		var angle_radians = deg_to_rad(shotgun_angle)
		
		# get the current segment of the angle we are currently on
		var angle = angle_radians / num_shotgun_bullets
		
		# for this iteration take the base fire_direction and move the angle based on current segment
		var rotation: float = (
								fire_direction.angle() + # get the fire direction as our center of the angle
								(angle * i) - # rotate by the current angle segment the bullet should be on
								(angle_radians/2)) # rotate the angle to have our angle center be the mid point of the angle
		
		# we want to right rotate or else the fire angle is 90 degrees off
		new_bullet.velocity = Vector2.RIGHT.rotated(rotation) * shotgun_bullet_speed 
		new_bullet.rotation = rotation
		
		# adjust stats and spawn
		new_bullet.damage = shotgun_bullet_damage
		new_bullet.z_index = z_index
		add_child(new_bullet)
		new_bullet.global_position = global_position
	
	# set cooldown
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
		# initialize the bullet and stats
		var new_bullet := wave_bullet.instantiate() as WaveBullet
		new_bullet.velocity = fire_direction * wave_bullet_speed
		new_bullet.rotation = fire_direction.angle()
		new_bullet.damage = wave_bullet_damage
		new_bullet.z_index = z_index
		add_child(new_bullet)
		new_bullet.global_position = global_position
	 
	# set cooldown
	_wave_weapon_timer = Timer.new()
	_wave_weapon_timer.one_shot = true
	add_child(_wave_weapon_timer)
	_wave_weapon_timer.start(wave_attack_cd * (2 - attack_speed))


func fire_scatter(enemy_position: Vector2) -> void:
	# get the normalized firing direction
	var fire_direction: Vector2 = (enemy_position - global_position).normalized()
	
	# initialize the bullet and stats
	var new_bullet := scatter_bullet.instantiate() as ScatterBullet
	new_bullet.velocity = fire_direction * scatter_bullet_speed
	new_bullet.rotation = fire_direction.angle()
	new_bullet.damage = scatter_bullet_damage
	new_bullet.bullet_speed = scatter_bullet_speed
	new_bullet.num_projectiles = num_scatter_bullets
	new_bullet.z_index = z_index
	add_child(new_bullet)
	new_bullet.global_position = global_position
	
	# set cooldown
	_scatter_weapon_timer = Timer.new()
	_scatter_weapon_timer.one_shot = true
	add_child(_scatter_weapon_timer)
	_scatter_weapon_timer.start(scatter_attack_cd * (2 - attack_speed))


func fire_chain(enemy_position: Vector2) -> void:
	# get the normalized firing direction
	var fire_direction: Vector2 = (enemy_position - global_position).normalized()
	
	# initialize the bullet and stats
	var new_bullet := chain_bullet.instantiate() as ChainBullet
	new_bullet.velocity = fire_direction * chain_bullet_speed
	new_bullet.rotation = fire_direction.angle()
	new_bullet.damage = chain_bullet_damage
	new_bullet.num_bounces = num_chain_bounces
	new_bullet.z_index = z_index
	add_child(new_bullet)
	new_bullet.global_position = global_position
	
	# set cooldown
	_chain_weapon_timer = Timer.new()
	_chain_weapon_timer.one_shot = true
	add_child(_chain_weapon_timer)
	_chain_weapon_timer.start(chain_attack_cd * (2 - attack_speed))


# helper function to adjust the z_index depending on what layer the player is supposed to be on
func adjust_z_index() -> void:
	# get coordianates of the tile player is standing on then get the tile data
	var player_tile_position:Vector2i = tile_map.local_to_map($Head.global_position - Vector2(0, 16))
	var new_z_index:int = -1
	
	# iterate through the current tile position starting from the top, if we see a slope or block, set the z_index to the z_index of the tile we saw
	for i in range(tile_map.layers.keys().size(), -1, -1):
		if (tile_map.get_cell_source_id(i, player_tile_position) != -1 &&
			tile_map.get_cell_atlas_coords(i, player_tile_position) not in tile_map.other &&
			tile_map.get_cell_atlas_coords(i, player_tile_position) != tile_map.boundery &&
			tile_map.get_cell_atlas_coords(i, player_tile_position) not in tile_map.wall_bounderies):
			new_z_index = i + 1
			break
	
	# if our new z_index is different from the current one, signal that the player entered a new layer to the tile_map
	if z_index != new_z_index && new_z_index > -1:
		signals.entered_new_layer.emit(max(new_z_index, 1), z_index)
	
	# if our new_z_index is valid, set z_index to the new one
	if new_z_index > -1:
		z_index = max(new_z_index, 1)


# helper function to check if player is on a slope
func is_on_slope() -> bool:
	# get coordianates of the tile player is standing on then get the tile data
	var player_tile_position:Vector2i = tile_map.local_to_map($Head.global_position - Vector2(0, 16))
	
	# check if there is a slope on the layer we are on and below as well
	return (tile_map.get_cell_atlas_coords(z_index, player_tile_position) in tile_map.slopes ||
			tile_map.get_cell_atlas_coords(z_index - 1, player_tile_position) in tile_map.slopes)
			

# add movement bias based on direction the player is moving in
func move_on_slope(input_vector : Vector2) -> void:
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


# teleport player to boss arena
func start_boss_fight() -> void:
	position.x = 1000
	position.y = -950


func create_smoke() -> void:
	var smoke := smoke_particles.instantiate() as SmokeParticles
	add_child(smoke)


func create_energy() -> void:
	var energy := energy_particles.instantiate() as EnergyParticles
	add_child(energy)


func on_dialogue_end() -> void:
	_dialogue = false


func end_intro() -> void:
	self.position.x = 0
	self.position.y = 0
	
	
# function that changes time scale for game
func change_time_scale(time_scale: float, duration: float) -> void:
	# set the time scale
	Engine.time_scale = time_scale
	
	# create the pause timer and wait for timer to expire, igoring the time scale
	await get_tree().create_timer(duration, true, false, true).timeout
	
	# set the time back to normal
	Engine.time_scale = 1
	

func _on_take_damage(damage : float) -> void:
	# only generate effects if we are not getting healed
	if damage >= 0:
		# generate hit effects
		Audio.player_hit.play()
		$hurtBox/CollisionShape2D.disabled = true # this is to prevent player from being hit during hit stun
		var blood := blood_particles.instantiate() as BloodParticles
		add_child(blood)
		signals.shake_camera.emit()
		change_time_scale(0.03, 0.75)
	
	# take away health
	health -= damage
	if health <= 0: # Making sure that health doesn't go negative
		health = 0
		Audio.death.play()
		get_tree().change_scene_to_file("res://Scenes/Death_Page.tscn")
	elif health > maxHeart:
		health = maxHeart
		
	healthChange.emit(health)
	$hurtBox/CollisionShape2D.disabled = false


func _on_player_stun(cc_timer: Timer, time: float) -> void:
	# stop the player
	velocity = Vector2(0, 0)
	
	# set up particles and cc_timer
	$Stun_Particles.visible = true
	_cc_timer = cc_timer
	add_child(_cc_timer)
	_cc_timer.start(time)


func _on_boss_death() -> void:
	signals.shake_camera.emit()
	change_time_scale(0.05, 2)


func _on_animated_sprite_2d_frame_changed() -> void:
	# if we are idle, do not make sound
	if $AnimatedSprite2D.animation == "idle": 
		return
	# if we are not idle, check tile type and play the corresponding sound
	if $AnimatedSprite2D.animation == "move":
		# WATER
		if get_tile_type() == 1:
			if Audio.walk_water.playing:
				return
			else:
				Audio.walk_water.play()
		# GRASS
		else:
			if Audio.walk_grass.playing:
				return
			else:
				Audio.walk_grass.play()
				
				
	
