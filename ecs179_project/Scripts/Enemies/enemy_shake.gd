class_name EnemyShake
extends AnimatedSprite2D


@export var shake_strength:float = 5
@export var fade: float = 7

var _cur_shake_strength = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _cur_shake_strength > 0:
		# lerp the shake strength to 0
		_cur_shake_strength = lerpf(_cur_shake_strength, 0, fade * delta)
		
		# randomly set a new position for the camera based on shake strength
		offset = Vector2(randf_range(-_cur_shake_strength, _cur_shake_strength),
						 randf_range(_cur_shake_strength, _cur_shake_strength))


func shake() -> void:
	_cur_shake_strength = shake_strength
