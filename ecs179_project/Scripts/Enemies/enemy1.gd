class_name Enemy1
extends Enemy

#NOTE: this was createdd only for testing the spawner

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	adjust_z_index(global_position)

	
