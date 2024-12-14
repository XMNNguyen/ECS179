class_name Boss1
extends Boss


enum state {
	ATTACK,
	IDLE,
	MOVE
}

@export var attack_cooldown: float = 0.8  
@export var projectile_scene: PackedScene = preload("res://Scenes/Enemies/Attacks/boss_attack.tscn")

var cur_state: state = state.IDLE
var attack_timer: Timer  
var blend_position: Vector2 = Vector2.ZERO
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


func _ready() -> void:
	# connect groups and signals
	add_to_group("Enemies")
	signals.take_damage.connect(_on_take_damage)

	# base stats
	base_speed = 50
	aggro_range = 250
	attack_range = 150
	soul_amount = randi_range(100, 150)
	
	# target player
	target = get_node_or_null("/root/World/Player")

	# cooldown for attack
	attack_timer = Timer.new()
	attack_timer.one_shot = true
	attack_timer.wait_time = attack_cooldown
	add_child(attack_timer)
	

# Called every frame
func _process(delta: float) -> void:
	# If our target is not set, make sure the target is our player
	if not target:
		target = get_node_or_null("/root/World/Player")
		return

	# adjust the z_index
	adjust_z_index(global_position)
	
	# if we are currently aggro on the target, start behavior script
	if _aggro:
		# do not move if we are attacking
		if cur_state == state.ATTACK:
			return  
		
		# if we are within attack range and our attack is off cooldown, start our attack
		if global_position.distance_to(target.global_position) <= attack_range:
			if attack_timer.is_stopped(): 
				start_attack()
				
		# otherwise move towards the target
		else:
			follow_target()
	
	# if we are within aggro range, set aggro to true
	elif global_position.distance_to(target.global_position) <= aggro_range:
		_aggro = true


func follow_target() -> void:
	# if we do not have a target, don't move
	if not target:
		return

	# move at player
	cur_state = state.MOVE
	var target_direction: Vector2 = (target.global_position - global_position).normalized()
	velocity = target_direction * base_speed
	move_and_slide()

	blend_position = Vector2(target_direction.x, -target_direction.y)


func start_attack() -> void:
	# if we do not have a target, do not attack
	if not target:
		return

	# set state to ATTACK
	cur_state = state.ATTACK

	# instantiate attack
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	projectile.target_position = target.global_position
	projectile.damage = base_damage
	projectile.z_index = z_index
	$"/root/World".add_child(projectile)

	# cooldown
	attack_timer.start()

	var target_direction: Vector2 = (target.global_position - global_position).normalized()
	blend_position = Vector2(target_direction.x, -target_direction.y)

	# reset
	call_deferred("reset_state")


func reset_state() -> void:
	cur_state = state.IDLE
	
