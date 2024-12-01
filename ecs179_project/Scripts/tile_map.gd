class_name TileMapController
extends TileMap

# NOTE: update this whenever we add new layers
enum layers{
	LEVEL_0 = 0,
	LEVEL_1 = 1,
	LEVEL_2 = 2,
	LEVEL_3 = 3,
}

# atlas coords of all boundery tiles
var boundery := Vector2i(9, 0)
var wall_bounderies:Dictionary = {
								Vector4i(0, 0, 1, 0) : Vector2i(9, 1),
								Vector4i(1, 0, 0, 0) : Vector2i(8, 1),
								Vector4i(0, 0, 0, 1) : Vector2i(8, 2),
								Vector4i(0, 1, 0, 0) : Vector2i(8, 0),
								Vector4i(1, 1, 0, 0) : Vector2i(9, 2),
								Vector4i(0, 0, 1, 1) : Vector2i(7, 0),
								Vector4i(0, 1, 1, 0) : Vector2i(9, 3),
								Vector4i(1, 0, 0, 1) : Vector2i(9, 4),
								Vector4i(1, 1, 0, 1) : Vector2i(4, 2),
								Vector4i(1, 0, 1, 1) : Vector2i(5, 2),
								Vector4i(1, 1, 1, 0) : Vector2i(6, 2),
								Vector4i(0, 1, 1, 1) : Vector2i(7, 2),
							  } 

# atlas coords of all the slopes in our tile set
var up_right_slopes:Array[Vector2i] = [Vector2i(1, 3)]
var right_slopes:Array[Vector2i] = [Vector2i(3, 3), Vector2i(3, 4)]
var down_right_slopes:Array[Vector2i] = [Vector2i(6, 3)]
var down_slopes:Array[Vector2i] = [Vector2i(8, 3), Vector2i(0, 4)]
var down_left_slopes:Array[Vector2i] = [Vector2(7, 3)]
var left_slopes:Array[Vector2i] = [Vector2i(5, 3), Vector2i(1, 4)]
var up_left_slopes:Array[Vector2i] = [Vector2i(2, 3)]
var up_slopes:Array[Vector2i] = [Vector2i(0, 3), Vector2i(2, 4)]
var slopes:Array[Vector2i] = (up_right_slopes + right_slopes + down_right_slopes + down_slopes +
							 down_left_slopes + left_slopes + up_left_slopes + up_slopes)

# atlas coords of all the blocks in our tile set
var blocks:Array[Vector2i] = [
							Vector2i(4, 3), Vector2i(4, 5), Vector2i(5, 5), Vector2i(0, 6),
							Vector2i(1, 6), Vector2i(2, 6), Vector2i(3, 6), Vector2i(4, 6),
							Vector2i(5, 6), Vector2i(1, 7), Vector2i(2, 7), Vector2i(3, 7),
							Vector2i(4, 7), Vector2i(5, 7), Vector2i(6, 7), Vector2i(7, 7),
							Vector2i(8, 9), Vector2i(9, 9),
							]

# atlas coords of other objects in tileset
var other:Array[Vector2i] = [
							Vector2i(0, 5), Vector2i(1, 5), Vector2i(2, 5), Vector2i(3, 5),
							Vector2i(6, 5), Vector2i(7, 5), Vector2i(8, 5), Vector2i(9, 5),
							Vector2i(6, 6), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 6),
							Vector2i(0, 7), Vector2i(0, 11), Vector2i(1, 11), Vector2i(2, 11),
							Vector2i(3, 11), Vector2i(4, 11), Vector2i(5, 11), Vector2i(6, 11),
							Vector2i(7, 11), Vector2i(8, 11), Vector2i(9, 11), Vector2i(0, 12),
							Vector2i(1, 12), Vector2i(2, 12), Vector2i(3, 12), Vector2i(4, 12),
							Vector2i(5, 12), Vector2i(6, 12), Vector2i(7, 12), Vector2i(8, 12),
							Vector2i(9, 12), Vector2i(0, 13), Vector2i(1, 13), Vector2i(2, 14),
							Vector2i(3, 14), Vector2i(4, 13), Vector2i(5, 13),
							]
							

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	signals.entered_new_layer.connect(entered_new_layer)
	setup_boundery(layers.LEVEL_1, 0)


# TODO: set up script to check player position and set up collision boxes accordingly
func _process(delta: float) -> void:
	pass
	

# NOTE: we are assuming that the player is set 1 layer above where they actually are due to Y-sort
# sets up a collision bounderies in the current layer

func clear_boundery(current_layer: layers, source: int):
	var offset_direction: Array[Vector2i] = [
											 Vector2i(-1, 0), Vector2i(1, 0), 
											 Vector2i(0, -1), Vector2i(0, 1)
											]
	var layer:Array[Vector2i]  = get_used_cells(current_layer - 1)
	
	# go through every tile in the layer
	# check the surrounding tiles around the currrent tile
	for tile in layer:
		# if the tile is a boundery tile, make it empty
		if (get_cell_atlas_coords(current_layer - 1, tile) == boundery or
			get_cell_atlas_coords(current_layer - 1, tile) in wall_bounderies.values()):
			set_cell(current_layer - 1, tile, -1)
	
	# go into the layer above i it exists and then add all the wall bounderies
	var layer_above:Array[Vector2i] = get_used_cells(current_layer)
	for tile in layer_above:
		# if the tile is a boundery tile, make it empty
		if (get_cell_atlas_coords(current_layer, tile) == boundery or
			get_cell_atlas_coords(current_layer, tile) in wall_bounderies.values()):
			set_cell(current_layer, tile, -1)


func setup_boundery(current_layer: layers, source: int):
	var offset_direction: Array[Vector2i] = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	var layer:Array[Vector2i]  = get_used_cells(current_layer - 1)
	
	# go through every tile in the layer
	# check the surrounding tiles around the currrent tile
	for tile in layer:
		# only place boundery tiles if the tile is a block
		if get_cell_atlas_coords(current_layer - 1, tile) in blocks:
			for offset in offset_direction:
				# if the tile we are checking is empty, place a boundery tile
				if get_cell_source_id(current_layer - 1, tile + offset) == -1:
					set_cell(current_layer - 1, tile + offset, source, boundery)
	
	# go into the layer above i it exists and then add all the wall bounderies
	var layer_above:Array[Vector2i] = get_used_cells(current_layer)
	for tile in layer_above:
		# only place boundery tiles if the tile is of type block
		if get_cell_atlas_coords(current_layer, tile) in blocks:
			# check each direction to see if there is an empty tile, and place the wall collision appropriately
			for offset in offset_direction:
				# place a boundery tile if empty
				if get_cell_source_id(current_layer, tile + offset) == -1:				
					# get the tiles surrounding the empty tile
					var cur_tile : Vector2i = tile + offset
					var tiles_surrounding : Vector4i = Vector4i(
																1 if is_block(current_layer, cur_tile + Vector2i(-1, 0)) else 0,
																1 if is_block(current_layer, cur_tile + Vector2i(0, -1)) else 0,
																1 if is_block(current_layer, cur_tile + Vector2i(1, 0)) else 0,
																1 if is_block(current_layer, cur_tile + Vector2i(0, 1)) else 0,
																)
					
					# assign the corresponding boundery tile based on tiles_surrounding										
					set_cell(current_layer, tile + offset, source, wall_bounderies[tiles_surrounding])


func entered_new_layer(layer: int, old_layer: int):
	# clear the old boundery and set up a new boundery in the new layer
	clear_boundery(old_layer, 0)
	setup_boundery(layer, 0)


# helper function that returns if a tile's atlas coords are of type block
func is_block(layer: int, atlas_coords: Vector2i) -> bool:
	return get_cell_atlas_coords(layer, atlas_coords) in blocks
