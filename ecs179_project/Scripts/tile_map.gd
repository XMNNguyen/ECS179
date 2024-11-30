extends TileMap

# NOTE: update this whenever we add new layers
enum layers{
	LEVEL_0 = 0,
	LEVEL_1 = 1,
	LEVEL_2 = 2,
	LEVEL_3 = 3,
}



var boundery := Vector2i(9, 0)
var wall_bounderies:Dictionary = {
								Vector2(-1, 0) : Vector2(9, 1),
								Vector2(1, 0) : Vector2(8, 1),
								Vector2(0, -1) : Vector2(8, 2),
								Vector2(0, 1) : Vector2(8, 0),
							  } 

# atlas coords of all the slopes in our tile set
var slopes:Array[Vector2] = [
							Vector2(0, 3), Vector2(1, 3), Vector2(2, 3), Vector2(3, 3), 
							Vector2 (5, 3), Vector2(6, 3), Vector2(7, 3), Vector2(8, 3), 
							Vector2(0, 4), Vector2(1, 4), Vector2(2, 4), Vector2(3, 4),
							]

# atlas coords of all the blocks in our tile set
var blocks:Array[Vector2] = [
							Vector2(4, 3), Vector2(4, 5), Vector2(5, 5), Vector2(0, 6),
							Vector2(1, 6), Vector2(2, 6), Vector2(3, 6), Vector2(4, 6),
							Vector2(5, 6), Vector2(1, 7), Vector2(2, 7), Vector2(3, 7),
							Vector2(4, 7), Vector2(5, 7), Vector2(6, 7), Vector2(7, 7),
							Vector2(8, 9), Vector2(9, 9),
							]

var other:Array[Vector2] = [
							Vector2(0, 5), Vector2(1, 5), Vector2(2, 5), Vector2(3, 5),
							Vector2(6, 5), Vector2(7, 5), Vector2(8, 5), Vector2(9, 5),
							Vector2(6, 6), Vector2(7, 6), Vector2(8, 6), Vector2(9, 6),
							Vector2(0, 7), Vector2(0, 11), Vector2(1, 11), Vector2(2, 11),
							Vector2(3, 11), Vector2(4, 11), Vector2(5, 11), Vector2(6, 11),
							Vector2(7, 11), Vector2(8, 11), Vector2(9, 11), Vector2(0, 12),
							Vector2(1, 12), Vector2(2, 12), Vector2(3, 12), Vector2(4, 12),
							Vector2(5, 12), Vector2(6, 12), Vector2(7, 12), Vector2(8, 12),
							Vector2(9, 12), Vector2(0, 13), Vector2(1, 13), Vector2(2, 14),
							Vector2(3, 14), Vector2(4, 13), Vector2(5, 13),
							]
							

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_boundery(layers.LEVEL_0, 0)


# TODO: set up script to check player position and set up collision boxes accordingly
func _process(delta: float) -> void:
	pass
	

# sets up a collision bounderies in the current layer
func setup_boundery(current_layer: layers, source: int):
	var offset_direction: Array[Vector2i] = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	var layer:Array[Vector2i]  = get_used_cells(current_layer)
	
	# go through every tile in the layer
	# check the surrounding tiles around the currrent tile
	for tile in layer:
		# only place boundery tiles if the tile is not a slope
		if get_cell_atlas_coords(current_layer, tile) not in slopes:
			for offset in offset_direction:
				# if the tile we are checking is empty, place a boundery tile
				if get_cell_source_id(current_layer, tile + offset) == -1:
					set_cell(current_layer, tile + offset, source, boundery)
	
	# go into the layer above i it exists and then add all the wall bounderies
	if current_layer + 1 < len(layers):
		var layer_above:Array[Vector2i] = get_used_cells(current_layer + 1)
		for tile in layer_above:
			# only place boundery tiles if the tile is of type block
			var tile_atlas_coords:Vector2 = get_cell_atlas_coords(current_layer + 1, tile)
			if tile_atlas_coords in blocks:
				# check each direction to see if there is an empty tile,
				# and place the wall collision appropriately
				for offset in offset_direction:
					if get_cell_source_id(current_layer + 1, tile + offset) == -1:
						set_cell(current_layer + 1, tile + offset, source, wall_bounderies[Vector2(offset)])
				
			
