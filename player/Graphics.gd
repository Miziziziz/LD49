extends Node2D


onready var shadow = $Shadow
var shadow_direction = Vector2.LEFT
var shadow_offset = 8.0

func _process(delta):
	shadow.global_position = global_position + shadow_direction*shadow_offset
