extends Node2D

var click_rate = 0.05
var click_rate_mod = 0.1
var last_click_time = 0.0
var radiation_detector

var min_pitch = 0.4
var max_pitch = 0.5

func _process(delta):
	var rad_str = radiation_detector.get_radiation_strength()
	if rad_str < 0.01:
		return
	
	if get_time() - last_click_time > click_rate:
		last_click_time = get_time()
		if rad_str < 0.2:
			if randi() % 2 == 0:
				play_click()
		else:
			play_click()
	
func play_click():
	var audio_player : AudioStreamPlayer = get_child(randi()%get_child_count())
	audio_player.pitch_scale = rand_range(min_pitch, max_pitch)
	audio_player.play()

func get_time():
	return OS.get_ticks_msec() / 1000.0
