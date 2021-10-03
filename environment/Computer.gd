extends StaticBody2D


onready var area = $Area2D
onready var computer_interface = $CanvasLayer/ComputerInterface
onready var line_edit = $CanvasLayer/ComputerInterface/LineEdit
var player

var power_available = 0
var fire_suppression = false
var life_support = true
var emergency_lights = true
var elevators = true

var top_line = "WBM PC\n_________________\n"

var commands_msg = """COMMANDS
status
power_off 'system_name'	|	EXAMPLE: power_off life_support
power_on 'system_name'	|	EXAMPLE: power_on life_support
commands
exit
"""

signal fire_suppression_turned_on

func _ready():
	computer_interface.hide()
	area.connect("body_entered", self, 'on_body_enter')
	line_edit.connect("text_entered", self, "parse_command")
	line_edit.connect("text_changed", self, "on_text_changed")

func on_text_changed(new_s):
	play_key_sound()

func on_body_enter(body):
	if "Player" in body.name:
		computer_interface.show()
		player = body
		player.in_interface = true
		set_process(false)
		line_edit.grab_focus()
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		display_msg("WELCOME - type 'commands' for available commands")
		$CompStartUpSound.play()
		$CompHum.play()

func parse_command(cmd_str: String):
	play_key_sound()
	cmd_str = cmd_str.strip_edges()
	line_edit.text = ""
	var cmds = cmd_str.split(" ")
	if cmds.size() == 0:
		return
	if cmds[0] == "commands":
		display_msg(commands_msg)
		return
	if cmds[0] == "status":
		display_status()
		return
	if cmds[0] == "exit":
		exit()
		return
	
	
	var set_power_on = false
	if cmds[0] == "power_off":
		set_power_on = false
	elif cmds[0] == "power_on":
		set_power_on = true
	else:
		display_error("incorrect command: %s" % cmd_str)
		return
	
	if cmds.size() == 1:
		display_error("no system specified")
		return
	
	var system = cmds[1]
	if !system in ["fire_suppression", "emergency_lights", "elevators", "life_support"]:
		display_error("system does not exist: " + system)
		return
	
	if get(system) == set_power_on:
		display_error("%s is already %s\n" % [system, bool_to_status(set_power_on)])
		return
	
	if !set_power_on:
		var power = 10
		if system == "fire_suppression":
			power = 30
		power_available += power
		set(system, set_power_on)
		display_msg(system + " is now offline")
		display_status()
	else:
		var power_needed = 10
		if system == "fire_suppression":
			power_needed = 30
		if power_available < power_needed:
			display_error("not enough power available")
			return
		power_available -= power_needed
		set(system, set_power_on)
		if system == "fire_suppression":
			emit_signal("fire_suppression_turned_on")
		#display_msg(system + " is now online")
		display_status()

func display_status():
	var status_msg = "STATUS\npower available: %d kW\n\n" % power_available
	status_msg += "fire_suppression - %s\n" % bool_to_status(fire_suppression)
	status_msg += "emergency_lights - %s\n" % bool_to_status(emergency_lights)
	status_msg += "elevators - %s\n" % bool_to_status(elevators)
	status_msg += "life_support - %s\n" % bool_to_status(life_support)
	display_msg(status_msg)

func bool_to_status(b):
	if b:
		return "online"
	return "offline"

func display_error(msg):
	display_msg("ERROR " + msg + "\n\ntype 'commands' for available commands")

func display_msg(msg: String):
	var new_msg = top_line
	new_msg += msg
	computer_interface.get_node("Label").text = new_msg

func exit():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	player.in_interface = false
	computer_interface.hide()
	$CompHum.stop()

func play_key_sound():
	$KeySounds.play()
	$CompHum.pitch_scale = rand_range(1.0, 2.0)
