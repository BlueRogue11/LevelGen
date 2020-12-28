#Dungeon holds all levels in a dungeon
#It also holds weighted drop data.

extends Node2D

#The hero of the game who will move through levels
var hero : Actor

#All levels in the dungeon will have to be saved most likely when the player is not on them, 
# so for now we'll have ONE level in memory.
#Eventually the dungeon will have to have a mechanism to save/load all the levels as needed.
var current_level
var num_levels = 0

onready var gen = get_node("Gates")

func _ready():
	current_level = gen.build_level()
	add_child(current_level)
	
func enter_dungeon(hero):
	current_level.enter_level_random(hero)
	current_level.make_active()
