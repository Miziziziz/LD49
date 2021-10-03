extends AnimationPlayer


func _ready():
	play("shake", -1, rand_range(0.95, 1.05))
	
