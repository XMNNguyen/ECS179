class_name ScatterBullet
extends CharacterBody2D


enum state {
			CREATE,
			TRAVELING, 
			DEATH,
			}

var damage: float = 1
var bullet_speed: float = 100
var num_projectiles: int = 5
var angle: float = 360
var time_to_live: float = 2
var will_scatter: bool = true

var scatter_bullet = preload("res://Scenes/Attacks/scatter_bullet.tscn")
var cur_state: state = state.CREATE
var state_keys = [
	"create",
	"traveling",
	"death"
]

var _timer:Timer

@onready var animationTree:AnimationTree = $AnimationTree
@onready var state_machine = animationTree["parameters/playback"]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_as_top_level(true)
	
	# add a death timer
	_timer = Timer.new()
	_timer.one_shot = true
	add_child(_timer)
	_timer.start(time_to_live)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move_and_slide()
	state_machine.travel(state_keys[cur_state])
	# once death timer is expired or bullet explodes, remove the bullet instance
	if _timer.time_left == 0 || state_machine.get_current_node() == "End":
		queue_free()


func scatter() -> void:
	for i in range(num_projectiles):
		var new_bullet := scatter_bullet.instantiate() as ScatterBullet
		
		# calculate the fire angle of this bullet
		# convert the shotgun angle into radians
		var angle_radians = deg_to_rad(angle)
		
		# get the current segment of the angle we are currently on
		var angle = angle_radians / num_projectiles
		
			# for this iteration take the base fire_direction and move the angle based on current segment
		var rotation: float = (
								velocity.normalized().angle() + # get the fire direction as our center of the angle
								(angle * i) - # rotate by the current angle segment the bullet should be on
								(angle_radians/2)) # rotate the angle to have our angle center be the mid point of the angle
		
		# we want to right rotate or else the fire angle is 90 degrees off
		new_bullet.velocity = Vector2.RIGHT.rotated(rotation) * bullet_speed 
		new_bullet.rotation = rotation
		new_bullet.global_position = global_position + (Vector2.RIGHT.rotated(rotation) * 20)
		
		# turns scatter off for these bullets
		new_bullet.will_scatter = false
		new_bullet.damage = damage
		new_bullet.time_to_live = 1
		new_bullet.z_index = z_index
		get_tree().root.add_child(new_bullet)


func _on_hit_box_area_entered(area: Area2D) -> void:
	# if we have entered the Player's hurtbox, explode the bullet
	if area.name == "hurtBox" && area.get_parent().is_in_group("Enemies"):
		area.get_parent()._on_take_damage(damage)
		velocity = Vector2(0, 0)
		if will_scatter:
			scatter()
		cur_state = state.DEATH
		state_machine.travel(state_keys[cur_state])
		state_machine.next()
