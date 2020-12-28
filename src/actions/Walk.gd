extends "res://src/actions/Action.gd"
var new_pos : Vector2

func _ready():
	self.name = "Walk"
	new_pos = Vector2(0,0)
	

func execute(level):
	if level.request_walk(actor,new_pos):
		return true
	return false
