extends Label


func _process(delta: float) -> void:
	self.text = str(souls_count.souls)
