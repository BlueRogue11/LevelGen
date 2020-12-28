extends Node2D
#The first dungeon the player enters.
var first_dungeon_path = "res://src/main/Dungeon.tscn"
#All the dungeons in the current game
var dungeon
#The main character... and their party?
var hero : Actor
onready var level_generator = $LevelGenerator
var level = null


func _ready():
	#Start the game, have the user create a hero.
	dungeon = load(first_dungeon_path).instance()
	add_child(dungeon)
	yield(get_tree(), "idle_frame")
	#hero = load("res://src/actors/Player.tscn").instance()
	#dungeon.enter_dungeon(hero)
			


	

	
