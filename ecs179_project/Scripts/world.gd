extends Node2D

@onready var heartContainer = $CanvasLayer/Hearts
@onready var player = %Player

func _ready() -> void:
	heartContainer.setMaxHearts(player.maxHeart)
	heartContainer.updateHearts(player.health)
	player.healthChange.connect(heartContainer.updateHearts)
	
	
func _process(delta: float) -> void:
	pass
