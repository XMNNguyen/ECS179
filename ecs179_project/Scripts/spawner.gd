class_name Spawner
extends Node2D

@export var enemy_types: Array[String] = ["res://Scenes/Enemies/chicken.tscn"] # holds all the scene paths of the types of enemies that can spawn in this spawner
@export var spawn_radius: float = 150
@export var trigger_radius:float = 70
@export var spawn_time: float = 1
@export var pack_spawn: bool = true
@export var pack_size: int = 3

var _spawn_timer: Timer

@onready var player: Player = %Player
@onready var tile_map: TileMap = %TileMap


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	refresh_spawn_timer()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# if the player is within radius of the spawner and spawn timer is stopped, spawn an enemy and refresh the timer
	if (player.global_position.distance_to(global_position) <= spawn_radius && 
	   (_spawn_timer == null || _spawn_timer.is_stopped())):
		
		if !pack_spawn:
			spawn_enemy()
		else:
			spawn_enemy_pack()
		
		# refresh the timer
		refresh_spawn_timer()


# helper function to spawn a random instance of a enemy
func spawn_enemy() -> void:
	# create a random enemy instance and add as a child
	var enemy_type: int = randi_range(0, len(enemy_types) - 1)
	var enemy: PackedScene = load(enemy_types[enemy_type])
	var enemy_instance := enemy.instantiate() as Enemy
	add_child(enemy_instance)
	
	# randomly set the spawn location somewhere around our spawner no more then spawn_radius away
	# if the spawn location is invalid (off map), change the spawn location
	var spawn_location: Vector2 = get_random_spawn_location()
	while (tile_map.get_cell_source_id(enemy_instance.z_index - 1, tile_map.local_to_map(spawn_location)) == -1 ||
			tile_map.get_cell_atlas_coords(enemy_instance.z_index - 1, tile_map.local_to_map(spawn_location)) == tile_map.boundery ||
			tile_map.get_cell_atlas_coords(enemy_instance.z_index - 1, tile_map.local_to_map(spawn_location)) in tile_map.wall_bounderies.values()):
		spawn_location = get_random_spawn_location()
		
	enemy_instance.global_position = spawn_location


func spawn_enemy_pack() -> void:
	for i in range(pack_size):
		spawn_enemy()


func refresh_spawn_timer() -> void:
	_spawn_timer = Timer.new()
	_spawn_timer.one_shot = true
	add_child(_spawn_timer)
	_spawn_timer.start(spawn_time)


func get_random_spawn_location() -> Vector2:
	return (
			global_position + 
			Vector2(randf_range(-spawn_radius, spawn_radius),
					randf_range(-spawn_radius, spawn_radius))
		   )
