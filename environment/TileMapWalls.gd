extends TileMap

var cur_scale = 1.0
var scal_inc_amnt = 0.05
var cur_modulate = 1.0
var modulate_inc_amnt = 0.4

var chance_to_be_beveled = 0.4
var num_of_layers = 2

func _ready():
	randomize_wall_blocks(self)
	for _i in range(num_of_layers):
		call_deferred("add_wall_layer")
	#get_tree().get_root().call_deferred("add_child", canvas_layer)

func randomize_wall_blocks(tilemap):
	for cell in tilemap.get_used_cells():
		if rand_range(0.0, 1.0) < chance_to_be_beveled:
			tilemap.set_cellv(cell, 1)
		else:
			tilemap.set_cellv(cell, 0)
			

func add_wall_layer():
	var canvas_layer = CanvasLayer.new()
	canvas_layer.follow_viewport_enable = true
	cur_scale += scal_inc_amnt
	canvas_layer.follow_viewport_scale = cur_scale
	
	var dup = duplicate(0)
	cur_modulate -= modulate_inc_amnt
	dup.modulate = Color(cur_modulate, cur_modulate, cur_modulate)
	randomize_wall_blocks(dup)
	
	get_tree().get_root().add_child(canvas_layer)
	canvas_layer.add_child(dup)
