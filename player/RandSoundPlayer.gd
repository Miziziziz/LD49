extends Node2D

export var min_pitch = 1.0
export var max_pitch = 1.0

func play():
	var audio_player = get_child(randi()%get_child_count())
	audio_player.pitch_scale = rand_range(min_pitch, max_pitch)
	audio_player.play()
