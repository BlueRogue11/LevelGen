#Data for a tile-based map, does not include the graphical representation itself, but tile information is found inside the individual tile objects.
#ToDo: Check over data protection for all properties.
extends Node
class_name Map
#Properties
var _tile_data setget tile_data_set, tile_data_get
var dimensions setget dimensions_set, dimensions_get 
var regions = []
var rooms = []
var num_rooms

func initialize(map : Array, regions : Array, rooms : Array):
	_tile_data = map.duplicate(true)
	dimensions = Vector2(_tile_data.size(),_tile_data[0].size())
	num_rooms = rooms.size()
	print(String(num_rooms))
	
	
func _ready():
	print("If this is called (MAP) then I don't know how ready works apparently.")
	pass # Replace with function body.

func to_string() -> String:
	return ("Map.gd: W/H:" + String(dimensions) + " #Rooms: " + String(rooms.size()))


#Tiles----------------------------------------------------
#Returns true if is a plain floor with no lava, deep water, etc.
func is_floor(location: Vector2):
	return get_tile(location).passable 


#Points---------------------------------------------------
func point_in_bounds(point : Vector2):
	if point.x < 0 || point.x >= dimensions.x: return false
	if point.y < 0 || point.y >= dimensions.y: return false
	return true

#Get a random free spot in a room.
#Will try tries # of times before returning null.
func random_spawn_location(max_tries : int = 10, allow_actor : bool = false, allow_object : bool = true):
	var tries = 0
	var location = Vector2(0,0)
	return location
	while tries < max_tries:
		tries += 1
		location = random_location_in_room(random_room())
		if !actor_at_point(location):
			return location
	print("Cannot find free spawn location, setting to 0,0")
	return null

func random_location_in_room(roomnum):
	var room = rooms[0]
	var x = util.rand_int(room.rect.position.x + 1, room.rect.position.x + room.rect.size.x - 1)
	var y = util.rand_int(room.rect.position.y + 1, room.rect.position.y + room.rect.size.y - 1)
	return Vector2(x,y)	

func random_room():
	return 0
	#return util.rand_int(0,rooms.size())
	
##Objects--------------------------------------------------
#func objects_in_room(room : int):
#	pass
#
##Actors---------------------------------------------------
#func actors_in_area(area: Rect2) -> Array:
#	pass
#
#func actors_in_room(room: int) -> Array:
#	pass
#
#func actors_around(point : Vector2, size : int) -> Array:
#	pass
#
#Returns the actor if there is one at point
func actor_at_point(point : Vector2):
	return get_tile(point).actor

func room_actor_is_in(actor : Actor):
	var num = 0
	for room in rooms:
		if room.rect.has_point(actor.tile_pos):
			return room
		num = num + 1
	return null 

func surrounding_points(a_point):
	var points = []
	var valid_points = []
	points = util.get_points_around(a_point)
	for point in points:
		if point_in_bounds(point):
			valid_points.append(point) 
	return valid_points

#Data protection------------------------------------------
#Protecting tile data, I don't want it set without checking for valid bounds.
#This really checks for out of bounds. Is this even necessary? returning null will certainly crash the game anyway
func get_tile(index):
	if point_in_bounds(index): return _tile_data[index.x][index.y]
	print("Map.gd: Warning: Invalid Index, returning null.")
	return null
	
func tile_data_set(value):
	return null 

func tile_data_get():
	print ("Map.gd: WARNING! Not safe. Use get_tile(index: Vector2)")
	return _tile_data

func dimensions_set(value):
	print("Map.gd: ERROR: Dimensions not set. Dimensions set on initializtion.")
	return null

func dimensions_get():
	return dimensions


