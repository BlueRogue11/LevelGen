#Handles pathfinding a tile based game.
#So the first function will return the closest path possible from A to B within a certain area (no bilbo fuckin' baggins).
#This should be set by a rectangle by the owner.  A square of 20x20 should be sufficent with the actor at the center (okay, 21x21, whatever).
#The actor will continue to follow this path as long as their target does not move. If their target does move then they have to recalculate
#to a free square around the target they have a path to. If there is no path they will just have to wait.
extends Node2D
class_name Pathfinder

onready var ground = AStar.new()
onready var actor_free = AStar.new()
var map setget set_map,get_map
var map_rect : Rect2
var traversable_tiles = null
var new_id = 0
var dungeon_size 
#The area to look for a path in. 
var local_area : Rect2

func set_map(value):
	if value != null:
		map = value
		map_rect = Rect2(0,0,map.size(),map[0].size())
		dungeon_size = Vector2(map.size(),map[0].size())
		
func get_map():
	return map
	
func initialize(a_map):
	self.map = a_map
	ground = AStar.new()
	traversable_tiles = []
	ground = find_ground_tiles()
	connect_tiles(ground)
	print("Editing in Vim!")
	actor_free = AStar.new()
	print("External Editor..")
	actor_free = find_ground_tiles()
	connect_tiles(actor_free)
	
func update_actor(old_point,new_point):		
	#Add Actor to new post
	var id = map[new_point.x][new_point.y].astar_id
	var points = get_surrounding(new_point)
	for p in points:
		actor_free.disconnect_points(map[p.x][p.y].astar_id,id)
		if !actor_at_location(p):
			actor_free.connect_points(id,map[p.x][p.y].astar_id,false)
	
	#Remove actor from old spot
	id = map[old_point.x][old_point.y].astar_id
	points = get_surrounding(old_point)
	for p in points:
		if !map.actor_at_point(p):
			actor_free.connect_points(map[p.x][p.y].astar_id,id,true)
		else:
			actor_free.connect_points(map[p.x][p.y].astar_id,id,false)		
	
func find_ground_tiles():
	var astar = AStar.new()
	for x in range(0,map.size()):
		for y in range(0,map[0].size()):
			if is_floor(Vector2(x,y)):
				astar.add_point(map[x][y].astar_id,Vector3(x,y,0))
	return astar

func is_free(location:Vector2):
	#Check if it is on AStar? It should be...
	if valid_location(location) && is_floor(location) && !actor_at_location(location):
		return true
	return false
	
func valid_location(location: Vector2):
	var x = location.x
	var y = location.y
	if x < 0 || x >= dungeon_size.x: return false
	if y < 0 || y >= dungeon_size.y: return false
	return true
#Connects all tiles on the A* grid with their surrounding tiles
#TODO Optimize
func connect_tiles(astar):
	# Loop over all tiles
	for x in range(map.size()):
		for y in range(map[x].size()):
			
			if astar.has_point(map[x][y].astar_id):
				var tiles = util.get_tiles_around(map,Vector2(x,y))
				for tile in tiles:
					if astar.has_point(tile.astar_id):
						astar.connect_points(map[x][y].astar_id, tile.astar_id, true)
						
#Get path to target. If find_alternate is true it will search out from the goal if there is no path directly there.
#ToDo: search_range is used to find how many steps away from goal to look for a good path.
#Removes the first location because that is where the actor is starting from.
func get_best_path(start : Vector2, goal : Vector2, find_alternate : bool = true, search_range : int = 1):
	var path = get_free_path(start,goal)
	if !path && find_alternate:
		var alternate_locations = get_surrounding_free(goal)
		if alternate_locations.size() > 0: 
			for point in alternate_locations:
				path = get_free_path(start,point)
#				print("Have an alternate path.")
				if path: break
	if path:
		var throwmeaway = path.pop_front()	
	return path

# Returns a path from start to end
func get_free_path(start, end):
	start = map[start.x][start.y].astar_id
	end = map[end.x][end.y].astar_id
	if not actor_free.has_point(start) or not actor_free.has_point(end):
		return null
	# Otherwise, find the map
	var path_map = actor_free.get_point_path(start, end)
	
	# Convert Vector3 array (remember, AStar is 3D) to tile locations
	var path = []
	for point in path_map:
		var v2point = Vector2(point.x, point.y)
		path.append(v2point)
	return path


# Returns a path from start to end
func get_astar_path(start, end):
	start = map[start.x][start.y].astar_id
	end = map[end.x][end.y].astar_id
	if not ground.has_point(start) or not ground.has_point(end):
		return null
	# Otherwise, find the map
	var path_map = ground.get_point_path(start, end)
	
	# Convert Vector3 array (remember, AStar is 3D) to tile locations
	var path = []
	for point in path_map:
		var v2point = Vector2(point.x, point.y)
		path.append(v2point)
	return path
	
func on_astar_map(point: Vector2):
	if ground.has_point(map[point.x][point.y].astar_id): return true
	return false
func get_surrounding_free(a_point):
	var points = []
	var walkable = []
	points = util.get_points_around(a_point)
	for point in points:
		if is_free(point):
			 walkable.append(point)
	return walkable
