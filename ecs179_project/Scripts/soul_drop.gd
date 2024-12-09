class_name SoulDrop
extends Node2D


@onready var player: Player = $"/root/World/Player"

var soul_amount: int = 1
var lerp_speed: float = 0.1

var _cur_lerp_speed: float = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_as_top_level(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move_to_player(delta)
	

func _on_hit_box_area_entered(area: Area2D) -> void:
	# if we have entered the Player's hurtbox, signal that the player has collected the soul
	if area.name == "hurtBox" && area.get_parent().name == "Player":
		signals.collect_soul.emit(soul_amount)
		queue_free()


# move the soul towards the player based on an interpolationcurve
func move_to_player(delta: float) -> void:
	if global_position.distance_to(player.global_position) <= player.collect_range:
		_cur_lerp_speed += delta * lerp_speed
		global_position = global_position.lerp(player.global_position, _cur_lerp_speed)
