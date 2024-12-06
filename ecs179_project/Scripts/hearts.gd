extends HBoxContainer

@onready var HeartGuiClass = preload("res://Scenes/Heart_Ui.tscn")

func _ready() -> void:
	pass 


func _process(delta: float) -> void:
	pass


func setMaxHearts(max:int): # Adds the max amount of heart container nodes
	for i in range(max):
		var heart = HeartGuiClass.instantiate()
		add_child(heart)


func updateHearts(currentHealth: float): # Updates the Heart containers
	var hearts = get_children()
	
	if currentHealth == int(currentHealth): # If health is a whole number, it will generate whole hearts
		for i in range(currentHealth):
			hearts[i].update(true)
		for i in range(currentHealth, hearts.size()):
			hearts[i].update(false)
	else:
		var whole_hearts = currentHealth # If health is not a whole number, it will generate a half heart for the 0.5 health
		var indices = 0
		while whole_hearts >= 1:
			hearts[indices].update(true)
			whole_hearts -= 1
			indices += 1
			
		for i in range(currentHealth, hearts.size()):
			hearts[i].update(false)
			
		hearts[indices].half_update(true)


	
