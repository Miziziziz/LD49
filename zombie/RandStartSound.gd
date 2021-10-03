extends AudioStreamPlayer2D



func _ready():
	var start_point = rand_range(0.0, stream.get_length())
	play(start_point)

