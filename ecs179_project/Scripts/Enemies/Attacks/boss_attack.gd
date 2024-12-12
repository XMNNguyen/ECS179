class_name BossAttack
extends CharacterBody2D

enum state {
	CREATE,
	TRAVELING, 
	ON_HIT,
}

@onready var animationTree: AnimationTree = $AnimationTree
@onready var state_machine = animationTree["parameters/playback"]

var cur_state: state = state.CREATE
var state_keys = [
	"create",
	"traveling",
	"on_hit"
]
var _timer: Timer

@export var target_position: Vector2 = Vector2.ZERO  # Position to move toward
@export var damage: int = 0  # Damage dealt to the player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Add a death timer
	_timer = Timer.new()
	_timer.one_shot = true
	add_child(_timer)
	_timer.start(2)

	cur_state = state.CREATE
	state_machine.travel(state_keys[cur_state])

# Initialize projectile properties
func initialize(target_pos: Vector2, damage_value: int) -> void:
	target_position = target_pos
	damage = damage_value
	cur_state = state.TRAVELING
	state_machine.travel(state_keys[cur_state])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state_machine.get_current_node() == "traveling":
		# Move towards the target position
		var direction = (target_position - global_position).normalized()
		velocity = direction * 200  # Adjust speed as needed
		move_and_slide()

	# Once death timer is expired or bullet explodes, remove the bullet instance
	if _timer.is_stopped() or state_machine.get_current_node() == "End":
		queue_free()

func _on_hit_box_area_entered(area: Area2D) -> void:
	# If we have entered the Player's hurtbox, explode the bullet
	if area.name == "hurtBox" and area.get_parent().name == "Player":
		velocity = Vector2(0, 0)
		cur_state = state.ON_HIT
		state_machine.travel(state_keys[cur_state])
		state_machine.next()
		signals.player_take_damage.emit(damage)
