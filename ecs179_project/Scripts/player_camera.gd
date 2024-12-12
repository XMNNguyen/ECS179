class_name PlayerCamera
extends Camera2D

@export var shake_strength:float = 30
@export var fade: float = 5

var _cur_shake_strength = 0

func _ready() -> void:
	signals.shake_camera.connect(_on_shake)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _cur_shake_strength > 0:
		_cur_shake_strength = lerpf(_cur_shake_strength, 0, fade * delta)
		
		offset = Vector2(randf_range(-_cur_shake_strength, _cur_shake_strength),
						 randf_range(_cur_shake_strength, _cur_shake_strength))


func _on_shake() -> void:
	_cur_shake_strength = shake_strength
