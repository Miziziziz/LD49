extends KinematicBody2D


var left_wheel_velocity = 0.0
var right_wheel_velocity = 0.0
var drag = 0.6

var torque_modifier = 0.05
var max_turn = 10.0
var speed_modifier = 2.0
var max_speed = 30.0

var mouse_last_pos = Vector2()

enum WHEELS {NONE, LEFT, RIGHT, BOTH}
var grabbed_wheel = WHEELS.NONE

var grab_time = 0.0
var max_grab_time = 0.1

export(Curve) var wheel_anim_curve
var dead = false


onready var spokes_r = $Graphics/SpokesR
onready var spokes_l = $Graphics/SpokesL
onready var arm_l = $Graphics/ArmL
onready var arm_r = $Graphics/ArmR
onready var body = $Graphics/Body

onready var health = $Health
onready var radiation_detector = $RadiationDetector
onready var geiger_counter = $GeigerCounter

var large_cursor = preload("res://player/assets/cursor.png")
var small_cursor = preload("res://player/assets/cursor_small.png")

var in_interface = false

func _ready():
	$ChairSpin.volume_db = linear2db(0.0)
	health.radiation_detector = radiation_detector
	geiger_counter.radiation_detector = radiation_detector
	health.connect("update_health_percent", self, "update_red_screen")
	health.connect("dead", self, "die")
	$CanvasLayer/DeathMessage/Button.connect("button_up", self, "restart")

func restart():
	get_tree().reload_current_scene()

func _process(delta):
	if !OS.has_feature("HTML5") and Input.is_action_just_pressed("exit"):
		get_tree().quit()
	update_cursor()

var c_move_amnt = 0.0
var max_c_move_amnt = 200.0
var movement_dir_complete = false
func _physics_process(delta):
	if in_interface:
		$ChairSpin.stop()
		right_wheel_velocity = 0.0
		left_wheel_velocity = 0.0
		return
	var mouse_pos = get_global_mouse_position()
	var mouse_offset = mouse_pos - mouse_last_pos
	var wheel_under_mouse = get_wheel_selected()
	
	if Input.is_action_just_pressed("main_move") and !dead:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		movement_dir_complete = false
		c_move_amnt = 0.0
		arm_l.play("idle")
		arm_r.play("idle")
		var cur_wheel = wheel_under_mouse
		if cur_wheel != WHEELS.NONE:
			grabbed_wheel = WHEELS.BOTH
			grab_time = get_time()
	if Input.is_action_just_pressed("alt_move") and !dead:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		movement_dir_complete = false
		c_move_amnt = 0.0
		arm_l.play("idle")
		arm_r.play("idle")
		grabbed_wheel = wheel_under_mouse
		if grabbed_wheel != WHEELS.NONE:
			grab_time = get_time()
			
	
#	if grabbed_wheel in [WHEELS.LEFT, WHEELS.RIGHT] and wheel_under_mouse in [WHEELS.LEFT, WHEELS.RIGHT] :
#		grab_time = get_time()
	
	if abs(c_move_amnt) > 200:
		grabbed_wheel = WHEELS.NONE

	
#	if (grabbed_wheel == WHEELS.BOTH or wheel_under_mouse == WHEELS.NONE) and get_time() - grab_time > max_grab_time:
#		grabbed_wheel = WHEELS.NONE
	
	if Input.is_action_just_released("main_move") or Input.is_action_just_released("alt_move"):
		grabbed_wheel = WHEELS.NONE
	
	var move_amnt = calc_move_amnt(mouse_offset)
	var p_c_move_amnt = c_move_amnt
	c_move_amnt += move_amnt
	
#	if abs(c_move_amnt) > max_c_move_amnt:
#		c_move_amnt = max_c_move_amnt * sign(c_move_amnt)
#		move_amnt = (max_c_move_amnt - abs(p_c_move_amnt)) * sign(c_move_amnt)
	
	if grabbed_wheel != WHEELS.NONE and abs(p_c_move_amnt) < 10 and abs(c_move_amnt) > 10:
		if !movement_dir_complete:
			if c_move_amnt > 0:
				$ChairSqueaks.play()
			else:
				$ChairCrunchs.play()
				
		movement_dir_complete = true
		var anim_name = "push_"
		if c_move_amnt > 0:
			anim_name += "fwd"
		else:
			anim_name += "bwd"
			
		if grabbed_wheel == WHEELS.BOTH:
			arm_l.play(anim_name)
			arm_r.play(anim_name)
		if grabbed_wheel == WHEELS.LEFT:
			arm_l.play(anim_name)
		if grabbed_wheel == WHEELS.RIGHT:
			arm_r.play(anim_name)
			

	if grabbed_wheel == WHEELS.BOTH:
		var velo = max(right_wheel_velocity, left_wheel_velocity)
		if sign(move_amnt) != sign(velo) and sign(move_amnt) != 0:
			velo = lerp(velo, move_amnt, 0.4)
		else:
			velo += move_amnt
		
		right_wheel_velocity = velo
		left_wheel_velocity = velo

	if grabbed_wheel in [WHEELS.LEFT, WHEELS.RIGHT]:
		if grabbed_wheel == WHEELS.RIGHT:
			right_wheel_velocity += move_amnt
		elif grabbed_wheel == WHEELS.LEFT:
			left_wheel_velocity += move_amnt
	
	
	var velo = right_wheel_velocity
	if abs(right_wheel_velocity) > abs(left_wheel_velocity):
		velo = left_wheel_velocity
	
	var turn_dir = 1.0
	if right_wheel_velocity > left_wheel_velocity:
		turn_dir = -1.0
	
	var torque = abs(right_wheel_velocity - left_wheel_velocity)
	#global_rotation_degrees += torque * turn_dir
	global_rotation_degrees += clamp(torque * turn_dir * torque_modifier, -max_turn, max_turn)
	
	
	var up_dir = transform.basis_xform(Vector2.UP)
	move_and_slide(up_dir * velo)
	
	var spin_vol = linear2db(0.0)
	var m_v = 20.0
	var t_v = 100.0
	if abs(velo) > m_v:
		var v = clamp((abs(velo)-m_v) / (t_v-m_v), 0.0, 1.0)
		spin_vol = linear2db(0.1*v)
	$ChairSpin.volume_db = spin_vol
	
#	velo -= velo * drag * delta
#	left_wheel_velocity = velo
#	right_wheel_velocity = velo
	left_wheel_velocity = lerp(left_wheel_velocity, velo, 0.3)
	right_wheel_velocity = lerp(right_wheel_velocity, velo, 0.3)
	
	left_wheel_velocity -= left_wheel_velocity * drag * delta
	right_wheel_velocity -= right_wheel_velocity * drag * delta
	mouse_last_pos = get_global_mouse_position()
	
	update_wheel_animations()

func calc_move_amnt(move_vec: Vector2):
	var up_dir = transform.basis_xform(Vector2.UP)
	var move_amnt = move_vec.dot(up_dir) * speed_modifier
	move_amnt = clamp(move_amnt, -max_speed, max_speed)
	return move_amnt

func get_wheel_selected():
	var mouse_pos = get_global_mouse_position()
	var world = get_world_2d().get_direct_space_state()
	var things = Utility.get_things_at_point(mouse_pos, 4, world, 10, false, true)
	if things.size() == 0:
		return WHEELS.NONE
	var thing_name = things[0].name
	if "Left" in thing_name:
		return WHEELS.LEFT
	return WHEELS.RIGHT
	
func get_time():
	return OS.get_ticks_msec() / 1000.0

func update_wheel_animations():
	var r_weight = clamp(abs(right_wheel_velocity) / 300.0, 0.0, 1.0)
	var l_weight = clamp(abs(left_wheel_velocity) / 300.0, 0.0, 1.0)
	
	var r_sp_scale = wheel_anim_curve.interpolate(r_weight)
	var l_sp_scale = wheel_anim_curve.interpolate(l_weight)
	spokes_r.speed_scale = r_sp_scale
	spokes_l.speed_scale = l_sp_scale
	
	spokes_l.play("spin", left_wheel_velocity < 0.0)
	spokes_r.play("spin", right_wheel_velocity < 0.0)

func update_cursor():
	var cursor = small_cursor
	if grabbed_wheel == WHEELS.NONE:
		cursor = large_cursor
	
	#Input.set_custom_mouse_cursor(cursor, 0, Vector2(8,8))

func update_red_screen(percent):
	$CanvasLayer/RedScreen.show()
	$CanvasLayer/RedScreen.color.g = percent
	$CanvasLayer/RedScreen.color.b = percent

func die():
	if dead:
		return
	dead = true
	body.play("die")
	arm_l.play("idle")
	arm_r.play("idle")
	grabbed_wheel = WHEELS.NONE
	$CanvasLayer/DeathMessage/AnimationPlayer.play("fadein")
	$DeathSound.play()
