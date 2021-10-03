extends KinematicBody2D


var nav : Navigation2D
var player : KinematicBody2D

var vision_arc = 30

export var turn_speed = 80.0
var move_speed = 60
var target_pos : Vector2

var player_visible_last_frame = false
var last_alert_sound_time = 0.0

var spotted_player = false

onready var legs = $Graphics/Legs

func _ready():
	target_pos = global_position
	legs.connect("frame_changed", self, "play_footstep")
	if get_tree().get_nodes_in_group("navigation").size() > 0:
		nav = get_tree().get_nodes_in_group("navigation")[0]
	if get_tree().get_nodes_in_group("player").size() > 0:
		player = get_tree().get_nodes_in_group("player")[0]

func _physics_process(delta):
	var player_visible = can_see_player()
	if player_visible:
		spotted_player = true
		if !player_visible_last_frame:# and get_time() - last_alert_sound_time > 2.0:
			$AlertSounds.play()
			#last_alert_sound_time = get_time()
	
	if spotted_player:
		target_pos = player.global_position
	
	var move_dir = Vector2()
	if global_position.distance_to(target_pos) < 40.0:
		legs.play("idle")
	
	if spotted_player:
		if nav:
			legs.play("walk")
			var path = nav.get_simple_path(global_position, target_pos)
			if path.size() > 1:
				move_dir = global_position.direction_to(path[1])
			face_point(move_dir*20 + global_position, delta)
		else:
			legs.play("walk")
			move_dir = global_position.direction_to(target_pos)
			face_point(target_pos, delta)
		if is_colliding_with_player():
			legs.play("idle")
	
	move_and_slide(move_dir * move_speed)
	player_visible_last_frame = player_visible
	

func can_see_player():
	var dir_to_player = global_position.direction_to(player.global_position)
	var up_dir = transform.basis_xform(Vector2.UP)
	var angle = dir_to_player.angle_to(up_dir)
	if abs(angle) > deg2rad(vision_arc):
		return false
	
	var space_state = get_world_2d().direct_space_state
	var has_los = space_state.intersect_ray(global_position, player.global_position, [], 1).size() == 0
	
	return has_los

func face_point(point: Vector2, delta: float):
	var l_point = to_local(point)
	
	var turn_dir = sign(l_point.x)
	var turn_amnt = deg2rad(turn_speed * delta)
	var angle = Vector2.UP.angle_to(l_point)
	
	if abs(angle) < turn_amnt:
		turn_amnt = abs(angle)
	
	global_rotation += turn_dir * turn_amnt

func get_time():
	return OS.get_ticks_msec()/1000.0

func play_footstep():
	var frame = legs.frame
	if frame in [1, 5]:
		$FootstepSounds.play()

func is_colliding_with_player():
	for i in range(get_slide_count()):
		if "Player" in get_slide_collision(i).collider.name:
			return true
	return false
