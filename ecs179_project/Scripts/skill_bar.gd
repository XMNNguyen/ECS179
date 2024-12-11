extends HBoxContainer

var slots : Array


func _ready():
	slots = get_children()
	
	for i in get_child_count():
		slots[i].change_key = str(i+1)
		slots[i].timer.wait_time = 1
		slots[i].cd.max_value = 1
		
	slots[0].change_key = str(1)
	slots[0].timer.wait_time = 1.5
	slots[0].cd.max_value = 1.5
	slots[0].texture_normal = preload("res://Assets/Projectile_Icon/Standard.jpg")
	
	
func _process(delta):
	if souls_count.souls >= 100:
		slots[1].change_key = str(2)
		slots[1].timer.wait_time = 4.5
		slots[1].cd.max_value = 4.5
		slots[1].texture_normal = preload("res://Assets/Projectile_Icon/Shotgun.jpg")
		
	if souls_count.souls >= 250:
		slots[2].change_key = str(3)
		slots[2].timer.wait_time = 6
		slots[2].cd.max_value = 6
		slots[2].texture_normal = preload("res://Assets/Projectile_Icon/Wave.jpg")
		
	if souls_count.souls >= 550:
		slots[0].texture_normal = preload("res://Assets/Projectile_Icon/Scatter.jpg")
		
	if souls_count.souls >= 900:
		slots[3].change_key = str(4)
		slots[3].timer.wait_time = 3
		slots[3].cd.max_value = 3
		slots[3].texture_normal = preload("res://Assets/Projectile_Icon/Chain.jpg")
		
	if Input.is_action_just_pressed("spell_1"):
		slots[0]._on_pressed()
	if Input.is_action_just_pressed("spell_2"):
		slots[1]._on_pressed()
	if Input.is_action_just_pressed("spell_3"):
		slots[2]._on_pressed()
	if Input.is_action_just_pressed("spell_4"):
		slots[3]._on_pressed()
