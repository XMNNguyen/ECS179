class_name SoulDrop
extends Node2D



var soul_amount: int = 1
var lerp_speed: float = 0.1

var _cur_lerp_speed: float = 0


@onready var player: Player = $"/root/World/Player"
@onready var tile_map: TileMap = $"/root/World/TileMap"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_as_top_level(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	adjust_z_index(global_position)
	move_to_player(delta)
	

func _on_hit_box_area_entered(area: Area2D) -> void:
	# if we have entered the Player's hurtbox, signal that the player has collected the soul
	if area.name == "hurtBox" && area.get_parent().name == "Player":
		signals.collect_soul.emit(soul_amount)
		Audio.pop.play()
		queue_free()


# move the soul towards the player based on an interpolationcurve
func move_to_player(delta: float) -> void:
	if global_position.distance_to(player.global_position) <= player.collect_range:
		_cur_lerp_speed += delta * lerp_speed
		global_position = global_position.lerp(player.global_position, _cur_lerp_speed)


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
