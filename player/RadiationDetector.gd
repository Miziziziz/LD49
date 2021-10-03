extends Area2D


onready var radius = $CollisionShape2D.shape.radius

func _process(delta):
	pass

func get_radiation_strength():
	var stren = 0.0
	var space_state = get_world_2d().direct_space_state
	for body in get_overlapping_bodies():
		var is_visible = space_state.intersect_ray(global_position, body.global_position, [], 1).size() == 0
		if !is_visible:
			continue
		var n_stren = global_position.distance_to(body.global_position) / radius
		n_stren = 1.0 - clamp(n_stren, 0.0, 1.0)
		if n_stren > stren:
			stren = n_stren
	return stren
