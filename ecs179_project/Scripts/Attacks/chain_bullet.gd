class_name ChainBullet
extends CharacterBody2D


enum state {
			BOUNCING,
			CREATE,
			TRAVELING, 
			}

@onready var animationTree:AnimationTree = $AnimationTree
@onready var state_machine = animationTree["parameters/playback"]

var damage: float = 1
var bounce_speed: float = 600
var bounce_distance: float = 150
var num_bounces: int = 5

var scatter_bullet = preload("res://Scenes/Attacks/scatter_bullet.tscn")
var cur_state: state = state.CREATE
var state_keys = [
	"bouncing",
	"create",
	"traveling",
]

var _timer:Timer
var _cur_bounce: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_as_top_level(true)
	
	# add a death timer
	_timer = Timer.new()
	_timer.one_shot = true
	add_child(_timer)
	_timer.start(2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move_and_slide()
	state_machine.travel(state_keys[cur_state])
	# once death timer is expired or bullet explodes, remove the bullet instance
	if _timer.time_left == 0 || _cur_bounce == num_bounces:
		queue_free()


func get_closest_enemy_position(enemy_hit: Enemy) -> Vector2:
	# get all enemies within our world scene
	var enemies_in_scene: Array[Node] = get_tree().get_nodes_in_group("Enemies")
	var closest_enemy_distance: float = 100000
	var closest_enemy_position: Vector2 = Vector2(100000, 100000)

	# iterate through every enemy comparing the distances to get the min distance from the player
	for enemy in enemies_in_scene:
		var enemy_distance: float = global_position.distance_to(enemy.global_position)
		if (enemy_distance < closest_enemy_distance && enemy != enemy_hit):
			closest_enemy_distance = enemy_distance
			closest_enemy_position = enemy.global_position
	
	# return the enemy's position that was the closest to the player
	return closest_enemy_position


func bounce(enemy_hit: Enemy) -> void:
	# refresh the timer each bounce
	_timer = Timer.new()
	_timer.one_shot = true
	add_child(_timer)
	_timer.start(0.2)
	
	# get the closest enemy position
	var closest_enemy_pos: Vector2 = get_closest_enemy_position(enemy_hit)
	
	# if closest enemy is within range, bounce to them, else keep the projectile still
	if closest_enemy_pos.distance_to(global_position) <= bounce_distance:
		var direction: Vector2 = (closest_enemy_pos - global_position).normalized()
		velocity = direction * bounce_speed
	else:
		velocity = Vector2(0, 0)
	_cur_bounce += 1


func _on_hit_box_area_entered(area: Area2D) -> void:
	# if we have entered the Player's hurtbox, change state and bounce the projectile
	if area.name == "hurtBox" && area.get_parent().is_in_group("Enemies"):
		$CPUParticles2D.visible = true
		area.get_parent()._on_take_damage(damage)
		velocity = Vector2(0, 0)
		cur_state = state.BOUNCING
		state_machine.travel(state_keys[cur_state])
		state_machine.next()
		bounce(area.get_parent())
