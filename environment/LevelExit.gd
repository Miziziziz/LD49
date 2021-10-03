extends Area2D

func _physics_process(delta):
	for body in get_overlapping_bodies():
		if "Player" in body.name and !body.dead:
			LevelManager.load_next_level()
