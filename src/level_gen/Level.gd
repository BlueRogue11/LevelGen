#Holds all information about a dungeon level
extends Node
var util = preload("res://util.gd")
class_name Level

signal map_changed
signal new_actor(actor)
signal hero_arrived(actor)


onready var region_display = $Region_Display
onready var turn_queue = $TurnQueue
onready var minimap_display = $Minimap_Display
onready var visibility_map = $VisibilityMap
onready var tilemap = $TileMap

var turn_num = 0 #move to global struct once ready to implement multiple levels

var action
var hero_in_level = false


var map #Game map containing the tiles

#Reminder: This is called when this Level becomes a child node. _ready is not a "constructor"
func _ready():
	region_display.regions = map.regions
	emit_signal("map_changed")
	
func next_action():
	var actor = turn_queue.active_actor
	action = yield(actor.get_node("AI").choose_action(self), "completed")
	turn_queue.preform_action(action)
	next_action()

func end_round():
	turn_num = turn_num + 1

	#Update scent map.
	# var remove = []
	# for x in range(map.size()):
		# for y in range(map[0].size()):
			# if map[x][y].scents.size() > 0:
				
				# for actor in map[x][y].scents.keys():
					# map[x][y].scents[actor] = map[x][y].scents[actor] - 1
					# if map[x][y].scents[actor] == 0:
						# remove.append(actor)
						
			# for actor in remove:
				# map[x][y].scents.erase(actor)
			# remove.clear()

func request_walk(actor : Actor, new_pos : Vector2) -> bool:
	var move = false
	if map.point_in_bounds(new_pos):
			move = true
	if move:
		# #Mark scent.
		# if actor.stats.has_scent && map[actor.tile_pos.x][actor.tile_pos.y].passable:
			# map[actor.tile_pos.x][actor.tile_pos.y].scents[actor] = 10
		set_actor_position(actor,new_pos)
		return true
	else: 
		return false

func make_active():
	if hero_in_level:
		next_action()
	else:
		print("No Main Character in this level, aborting...")
		return null
	turn_queue.connect("round_end",self,"end_round")
	turn_queue.give_energy()
func get_active_actor():
	return turn_queue.active_actor
func spawn_actor_random(scene_name : String):
	var actor = load(scene_name).instance()
	add_actor(actor)
	set_actor_position(actor,map.random_spawn_location(false,false))

func spawn_actor_in_room(scene_name : String, room_num : int):
	var actor = load(scene_name).instance()
	add_actor(actor)
	set_actor_position(actor, map.random_location_in_room(map.rooms[room_num]))
	
func enter_level_random(actor):
	add_actor(actor)
	set_actor_position(actor,Vector2(0,0))
	
func add_actor(actor : Actor):
	#Make sure visibility is attached to the player's character.
	if actor.is_main_character:
		hero_in_level = true
		emit_signal("hero_arrived",actor)
		visibility_map.initialize(self,actor,minimap_display)
	else:
		emit_signal("new_actor", actor)
	return actor
	
func set_actor_position(actor, position : Vector2):
	map.get_tile(actor.tile_pos).actor = null
	map.get_tile(position).actor = actor
	actor.tile_pos = position
	emit_signal("map_changed")

#Visiblity ------
#Feel like this stuff should be elsewhere...
#I'm not sure where visibility will be yet, so it is staying here. Maybe attached to individual actors?
func actor_can_see(actor, target):
	if get_visible_actors(actor).size() > 0 && get_visible_actors(actor).has(target) : return true
	return false
	
func get_visible_actors(actor : Actor):
	var room = map.room_actor_is_in(actor)
	var actors = []
	if room:
		actors = actors_in_area(room.rect)
		var visible_area = util.get_rect_around_point(actor.tile_pos,2)
		for a in actors_in_area(visible_area):
			actors.append(a)
	else: 
		var visible_area = util.get_rect_around_point(actor.tile_pos,2)
		actors = actors_in_area(visible_area)
	return actors
	
func actors_in_area(area):
	var actors = []
	var possible = turn_queue.get_actors()
	for actor in possible:
		if area.has_point(actor.tile_pos):
			actors.append(actor)
	return actors


