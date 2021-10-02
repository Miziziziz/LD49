extends TileMap

var chance_to_be_beveled = 0.2

func _ready():
	for cell in get_used_cells():
		if rand_range(0.0, 1.0) > chance_to_be_beveled:
			set_cellv(cell, 1)
		else:
			set_cellv(cell, 0)
