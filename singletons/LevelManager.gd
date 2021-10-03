extends Node

var level_ind = 0
var level_list = [
	"res://levels/Tutorial.tscn",
	"res://levels/RadioactiveFallout.tscn",
	"res://levels/Warren.tscn",
	"res://levels/ClearChannels.tscn",
	"res://levels/PuzzleRoom.tscn",
	"res://levels/Run.tscn",
	"res://levels/FinalScene.tscn",
	"res://levels/Outro.tscn"
]

func load_next_level():
	level_ind += 1
	level_ind %= level_list.size()
	get_tree().call_group("instanced", "queue_free")
	get_tree().change_scene(level_list[level_ind])
	
