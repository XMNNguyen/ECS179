extends TileMap

# NOTE: update this whenever we add new layers
enum layers{
	LEVEL_0 = 0,
	LEVEL_1 = 1,
	LEVEL_2 = 2,
	LEVEL_3 = 3,
}


# TODO: set up a couple more invisible collision tiles for tiles 1 layer above
var boundery := Vector2i(9, 0)

# TODO: fill out the slopes table of all the atlas coords of slopes
# atlas coords of all the slopes in our tile set
var slopes:Array[Vector2] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_boundery(layers.LEVEL_0, 0)


# TODO: set up script to check player position and set up collision boxes accordingly
func _process(delta: float) -> void:
	pass
	

# sets up a collision boundery in the current layer
func setup_boundery(current_layer: layers, source: int):
	var offset_direction: Array[Vector2i] = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]
	var layer:Array[Vector2i]  = get_used_cells(current_layer)
	
	# go through every tile in the layer
	# check the surrounding tiles around the currrent tile
	for tile in layer:
		for offset in offset_direction:
			# if the tile we are checking is empty, place a boundery tile
			if get_cell_source_id(current_layer, tile + offset) == -1:
				set_cell(current_layer, tile + offset, source, boundery)
				
	# TODO: do one more set of checks on the layer above currrent_layer and add the corresponding collision bounderies for the walls
				
			
