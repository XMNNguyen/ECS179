class_name Troll
extends Enemy


enum state {
			ATTACK,
			IDLE, 
			MOVE
			}

@onready var animationTree:AnimationTree = $AnimationTree
@onready var state_machine = animationTree["parameters/playback"]

var wind_up_timer:Timer
var stun_timer:Timer
var cooldown_timer:Timer

var stun_time: float = 0.5
var cooldown: float = 2.75

var cur_state: state = state.IDLE
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
var _attacking: bool = false
var _grabbing: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Enemies")
	signals.take_damage.connect(_on_take_damage)
	signals.boss_died.connect(_on_boss_died)
	
	# adjust base stats
	base_damage = 1
	base_speed = 60
	aggro_range = 300
	attack_range = 100
	soul_amount = randi_range(8, 12)
	target = $"/root/World/Player"
	adjust_z_index($Head.global_position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	adjust_z_index($Head.global_position)
	# check if the chicken has aggro on it's target
	if _aggro:
		# if we are grabbing the player, keep the troll still
		if _grabbing && !stun_timer.is_stopped():
			$hitBox/CollisionShape2D.disabled = true
			velocity = Vector2(0, 0)
		# check if we are attacking and if the windup timer is stopped, execute a small dash
		elif cur_state == state.ATTACK && (wind_up_timer == null || wind_up_timer.is_stopped()):
			grab_attack()
		# if we are not attacking, start movement
		elif cur_state != state.ATTACK:
			$hitBox/CollisionShape2D.disabled = true
			follow_target()
			# if we are in attack range, commence peck attack
			if (global_position.distance_to(target.global_position) <= attack_range
			 	&& (cooldown_timer == null || cooldown_timer.is_stopped())):
				start_charge_attack()
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


func start_charge_attack() -> void:
	# set state to attack state and get the direction towards the target
	cur_state = state.ATTACK
	var target_direction: Vector2 = (target.global_position - global_position).normalized()
	
	# set up a wind up timer before chicken launches itself
	wind_up_timer = Timer.new()
	wind_up_timer.one_shot = true
	add_child(wind_up_timer)
	velocity = Vector2(0, 0)
	wind_up_timer.start(0.56)
	
	# start cooldown timer
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	add_child(cooldown_timer)
	cooldown_timer.start(cooldown)
	
	# update state machine
	blend_position = Vector2(target_direction.x, -target_direction.y)
	move_and_slide()
	state_machine.travel(state_keys[cur_state])
	animationTree.set(blend_paths[cur_state], blend_position)


func grab_attack() -> void:
		# if the wind up timer just ended, launch the chicken in direction of target
		$hitBox/CollisionShape2D.disabled = false
		if !_attacking:
			var target_direction: Vector2 = (target.global_position - global_position).normalized()
			velocity = target_direction * 325
			_attacking = true
			move_and_slide()
		# start slowing down the chicken
		elif _attacking && abs(velocity) >= Vector2(10, 10):
			velocity *= 0.95
			move_and_slide()
		# the peck attack has ended
		else:
			cur_state = state.MOVE
			_attacking = false


func stun() -> void:
	# create a new timer for stun time and emit the stun signal for player
	_grabbing = true
	stun_timer = Timer.new()
	stun_timer.one_shot = true
	signals.player_stunned.emit(stun_timer, stun_time)
	
	# add timer as child since we use it to keep troll still as well
	add_child(stun_timer)
	stun_timer.start(stun_time)


func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.name == "hurtBox" && area.get_parent().name == "Player":
		stun()
		signals.player_take_damage.emit(base_damage)


func _on_boss_died() -> void:
	# kill of enemy and replace with smoke particles
	self._current_health = 0
	var smoke_instance := smoke_scene.instantiate() as SmokeParticles
	$"/root/World".add_child(smoke_instance)
	smoke_instance.emitting = true
	smoke_instance.z_index = z_index + 1
	smoke_instance.global_position = global_position
	self.die()
