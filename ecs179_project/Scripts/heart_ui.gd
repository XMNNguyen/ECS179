extends Panel


@onready var sprite: Sprite2D = $Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update(health: bool):
	if health:
		sprite.frame = 4 # Generates a whole heart
	else: 
		sprite.frame = 0 # Generates a heart container


func half_update(health: bool): # Generates a half heart
	sprite.frame = 2
