class_name Enemy1
extends Enemy

#NOTE: this was createdd only for testing the spawner

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# NOTE: when we start making enemy scenes, we probably should adjust the z_index based on the head position since we are doing an isometric game,
	# 	    it will most likely be very similar to how I did it for player.gd
	adjust_z_index(global_position)
	_current_health -= 1
	die()
	

	
