extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed_start() -> void:
	souls_count.souls = 0
	Engine.time_scale = 1
	get_tree().change_scene_to_file("res://Scenes/world.tscn")


func _on_button_pressed_options() -> void:
	get_tree().change_scene_to_file("res://Scenes/Controls.tscn")


func _on_button_pressed_quit() -> void:
	get_tree().quit()


func _on_button_pressed_back() -> void:
	get_tree().change_scene_to_file("res://Scenes/Starting_Menu.tscn")


func _on_start_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Starting_Menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Credits.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Starting_Menu.tscn")


func _on_back_pressed_credit() -> void:
	get_tree().change_scene_to_file("res://Scenes/Victory.tscn")
