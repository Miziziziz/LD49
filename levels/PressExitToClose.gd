extends Control



func _process(delta):
	if !OS.has_feature("HTML5") and Input.is_action_just_pressed("exit"):
		get_tree().quit()
