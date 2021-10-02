extends Node2D

class_name Utility

static func get_things_at_point(point: Vector2, layer_mask, world, grab_radius=10, collide_bodies=true, collide_areas=false):
	var query = Physics2DShapeQueryParameters.new()
	var select_transform = Transform2D()
	select_transform.origin = point
	query.set_transform(select_transform)
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = grab_radius
	query.set_shape(circle_shape)
	query.collision_layer = layer_mask
	query.collide_with_bodies = collide_bodies
	query.collide_with_areas = collide_areas
	var space_state = world#get_world_2d().get_direct_space_state()
	var result = space_state.intersect_shape(query)
	var objects = []
	for item_data in result:
		objects.append(item_data.collider)
	return objects
