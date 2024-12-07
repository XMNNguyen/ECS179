class_name Chicken
extends Enemy

enum state {
			ATTACK,
			IDLE, 
			MOVE
			}

@onready var animationTree:AnimationTree = $AnimationTree
@onready var state_machine = animationTree["parameters/playback"]

var cur_state: state = state.IDLE
var on_slope: bool = false
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_speed = 40
	aggro_range = 100
	target = $"/root/World/Player"
	adjust_z_index($Head.global_position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	adjust_z_index($Head.global_position)
	if _aggro:
		follow_target()
	elif global_position.distance_to(target.global_position) <= aggro_range:
		_aggro = true


func follow_target() -> void:
	cur_state = state.MOVE
	var target_direction: Vector2 = (target.global_position - global_position).normalized()
	velocity = target_direction * base_speed
	
	if is_on_slope($Head.global_position):
		on_slope = true
		move_on_slope(target_direction, $Head.global_position, 15, 5)
	elif on_slope:
		on_slope = false
	
	
	blend_position = Vector2(target_direction.x, -target_direction.y)
	move_and_slide()
	state_machine.travel(state_keys[cur_state])
	animationTree.set(blend_paths[cur_state], blend_position)
	#print("cur_state: " + str(cur_state))
	#print(state_machine.get_current_node())
	
