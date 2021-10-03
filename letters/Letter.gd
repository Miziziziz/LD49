extends Node2D

onready var area = $Area2D
onready var letter_display = $CanvasLayer/Letter
onready var paper_sound = $PaperSound
var player

func _ready():
	letter_display.hide()
	area.connect("body_entered", self, 'on_body_enter')

func on_body_enter(body):
	if "Player" in body.name:
		letter_display.show()
		player = body
		player.in_interface = true
		paper_sound.play()

func close_letter():
	letter_display.hide()
	player.in_interface = false
	paper_sound.play()
