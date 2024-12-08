class_name Sprout
extends Enemy

enum state {
			ATTACK,
			IDLE, 
			MOVE
			}

@onready var animationTree:AnimationTree = $AnimationTree
@onready var state_machine = animationTree["parameters/playback"]

var cur_state: state = state.IDLE
var wind_up_timer:Timer
var blend_position : Vector2 = Vector2.ZERO
var blend_paths = [
	"parameters/Attack/attack_blend/blend_position",
	"parameters/Idle/idle_blend/blend_position",
	"parameters/Move/move_blend/blend_position"
]
var state_keys = [
	"Attack",
	"Idle",
	"Move"
]
var bullet = preload("res://Scenes/Enemies/Attacks/sprout_bullet.tscn")
var projectile_speed: float = 120

var _on_slope: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# adjust base stats
	base_speed = 40
	aggro_range = 150
	attack_range = 120
	target = $"/root/World/Player"
	adjust_z_index($Head.global_position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	adjust_z_index($Head.global_position)
	# check if the sprout has aggro on it's target
	if _aggro:
		if cur_state != state.ATTACK:
			follow_target()
			# if we are in attack range, commence peck attack
			if global_position.distance_to(target.global_position) <= attack_range:
				start_fire()
	elif global_position.distance_to(target.global_position) <= aggro_range:
		_aggro = true


func follow_target() -> void:
	# change our state to MOVE and set the velocity to be in the direction towards the player
	cur_state = state.MOVE
	var target_direction: Vector2 = (target.global_position - global_position).normalized()
	velocity = target_direction * base_speed
	
	# adjust movement based on if we are on a slope
	if is_on_slope($Head.global_position):
		_on_slope = true
		move_on_slope(target_direction, $Head.global_position, 15, 5)
	elif _on_slope:
		_on_slope = false
	
	# adjust the state machine
	blend_position = Vector2(target_direction.x, -target_direction.y)
	move_and_slide()
	state_machine.travel(state_keys[cur_state])
	animationTree.set(blend_paths[cur_state], blend_position)


func start_fire() -> void:
	# set up blend position and change state to attack
	var target_direction: Vector2 = (target.global_position - global_position).normalized()
	cur_state = state.ATTACK
	velocity = Vector2(0, 0)
	
	blend_position = Vector2(target_direction.x, -target_direction.y)
	move_and_slide()
	state_machine.travel(state_keys[cur_state])
	animationTree.set(blend_paths[cur_state], blend_position)


func fire() -> void:
	# create bullet instance and base velocity on projectile speed and rotate the bullet towards player
	var fire_direction: Vector2 = (target.global_position - global_position).normalized()
	var new_bullet := bullet.instantiate() as SproutBullet
	new_bullet.velocity = fire_direction * projectile_speed
	new_bullet.rotation = fire_direction.angle()
	add_child(new_bullet)

	cur_state = state.MOVE
