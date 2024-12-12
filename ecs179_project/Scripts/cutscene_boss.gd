extends Node2D


var smoke_particles = preload("res://Scenes/smoke_particles.tscn")

func become_visible() -> void:
	self.visible = true
	
func become_invisible() -> void:
	self.visible = false
	
func create_smoke() -> void:
	var smoke := smoke_particles.instantiate() as SmokeParticles
	add_child(smoke)
