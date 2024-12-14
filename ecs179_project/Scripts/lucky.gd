extends Node2D


var smoke_particles = preload("res://Scenes/smoke_particles.tscn")


func become_invisible() -> void:
	self.visible = false


func create_smoke() -> void:
	var smoke3 := smoke_particles.instantiate() as SmokeParticles
	add_child(smoke3)
