extends Node2D

@onready var heartContainer = $CanvasLayer/Hearts
@onready var player = %Player
@onready var lucky = %Lucky
@onready var cutsceneBoss = %CutsceneBoss

func _ready() -> void:
	heartContainer.setMaxHearts(player.maxHeart)
	heartContainer.updateHearts(player.health)
	player.healthChange.connect(heartContainer.updateHearts)
	
	
func _process(delta: float) -> void:
	pass
