extends Node

class_name Action

export var energy_cost = 1000

onready var actor : Actor = get_parent().get_owner()

export(String) var description : String = "Base combat action"

func execute(level):
	print("%s missing overwrite of the execute method" % name)
	return false
