class_name SproutBullet
extends CharacterBody2D


enum state {
			CREATE,
			TRAVELING, 
			DEATH,
			}

var damage: float = 0.5
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
	# add a death timer
	_timer = Timer.new()
	_timer.one_shot = true
	add_child(_timer)
	_timer.start(2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move_and_slide()
	# once death timer is expired or bullet explodes, remove the bullet instance
	if _timer.time_left == 0 || state_machine.get_current_node() == "End":
		queue_free()


func _on_hit_box_area_entered(area: Area2D) -> void:
	# if we have entered the Player's hurtbox, explode the bullet
	if area.name == "hurtBox" && area.get_parent().name == "Player":
		velocity = Vector2(0, 0)
		cur_state = state.DEATH
		state_machine.travel(state_keys[cur_state])
		state_machine.next()
		signals.player_take_damage.emit(damage)
