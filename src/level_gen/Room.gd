
#Defines a room
extends Node2D
class_name Room
var rect = Rect2(0,0,1,1)
var doors = []
var corners = []
var is_visible = false
var is_dark = false

func init(_rect):
	rect = _rect
	
	#Get the corners
	corners.append(Vector2(rect.position.x,rect.position.y))
	corners.append(Vector2(rect.position.x + rect.size.x - 1, rect.position.y))
	corners.append(Vector2(rect.position.x,rect.position.y + rect.size.y - 1))
	corners.append(Vector2(rect.position.x + rect.size.x -1, rect.position.y + rect.size.y -1))
#return position of a random door

func get_random_door():
	if doors == null:
		return null
	else:
		return doors[randi() % doors.size()]
	
func _ready():
	pass
