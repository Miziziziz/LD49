extends Node2D

var hp_regen_rate = 1.0
var max_hp = 10.0
var cur_hp = max_hp

var radiation_detector
var rad_damage_rate = 3.0

signal dead
signal update_health_percent

func _process(delta):
	if radiation_detector == null:
		return
	
	var r_str = radiation_detector.get_radiation_strength()
	if r_str < 0.01:
		cur_hp += hp_regen_rate * delta
	else:
		cur_hp -= rad_damage_rate * delta
	
	if cur_hp < 0.0:
		emit_signal("dead")
		set_process(false)
	
	cur_hp = clamp(cur_hp, 0.0, max_hp)
	emit_signal("update_health_percent", cur_hp / max_hp)
