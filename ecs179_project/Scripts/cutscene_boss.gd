extends Sprite2D

@onready var animation_player = $AnimationPlayer


func become_visible() -> void:
	print("Visible")
	self.visible = true
	#animation_player.play("appear")
	
