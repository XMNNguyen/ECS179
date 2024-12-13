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

var _on_slope: bool = false
var _pecking: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Enemies")
	signals.take_damage.connect(_on_take_damage)
	signals.boss_died.connect(_on_boss_died)
	
	# adjust base stats
	base_speed = 40
	aggro_range = 300
	attack_range = 60
	soul_amount = randi_range(5, 10)
	target = $"/root/World/Player"
	adjust_z_index($Head.global_position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	adjust_z_index($Head.global_position)
	# check if the chicken has aggro on it's target
	if _aggro:
		# check if we are pecking and if the windup timer is stopped, execute a small dash
		if cur_state == state.ATTACK && (wind_up_timer == null || wind_up_timer.is_stopped()):
			peck_attack()
		elif cur_state != state.ATTACK:
			follow_target()
			# if we are in attack range, commence peck attack
			if global_position.distance_to(target.global_position) <= attack_range:
				start_peck_attack()
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


func start_peck_attack() -> void:
	# set state to attack state and get the direction towards the target
	cur_state = state.ATTACK
	var target_direction: Vector2 = (target.global_position - global_position).normalized()
	
	# set up a wind up timer before chicken launches itself
	wind_up_timer = Timer.new()
	wind_up_timer.one_shot = true
	add_child(wind_up_timer)
	velocity = Vector2(0, 0)
	wind_up_timer.start(0.56)
	
	# update state machine
	blend_position = Vector2(target_direction.x, -target_direction.y)
	move_and_slide()
	state_machine.travel(state_keys[cur_state])
	animationTree.set(blend_paths[cur_state], blend_position)


func peck_attack() -> void:
		# if the wind up timer just ended, launch the chicken in direction of target
		if !_pecking:
			var target_direction: Vector2 = (target.global_position - global_position).normalized()
			velocity = target_direction * 230
			_pecking = true
			move_and_slide()
			Audio.chicken_attack.play()
		# start slowing down the chicken
		elif _pecking && abs(velocity) >= Vector2(10, 10):
			velocity *= 0.95
			move_and_slide()
		# the peck attack has ended
		else:
			cur_state = state.MOVE
			_pecking = false


func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.name == "hurtBox" && area.get_parent().name == "Player":
		signals.player_take_damage.emit(base_damage)

func _on_boss_died() -> void:
	self._current_health = 0
	self.die()
