#Generates Dungeon Levels using BSP and returns a map of tiles to draw it with.

#Binary Space Partioning divides an area based on constraints given to it.  Each area is called a leaf.
#	This forms a tree with the area you start with being the root leaf and its children making up the areas inside it.
#	The leafs that have no children have never been decided. It is these leafs we can put dungeon features into without
#	fearing overlap.
#See https://gamedevelopment.tutsplus.com/tutorials/how-to-use-bsp-trees-to-generate-game-maps--gamedev-12268 for more information.
#	Thank you to Timothy Hely for this excellent information!

#This example does not use Timothy Hely's method of making pathways between rooms.  
#	I based my solution off of Thoughquake's video "Building a Roguelike from Scratch in Godot..."
#	https://youtu.be/vQ1UGbUlzH4
# 	Thank you Thoughtquake for the great tutorial!
extends Node2D
var util = preload("res://util.gd")
#How big is the dungeon level? 
export var dungeon_size = Vector2(40,20)

export var tile_set : Resource
export var spawner : Resource

#How much bigger must a leaf be then the maximum size room? Setting this to 1 will make regions just big enough for the largest rooms.
export var max_leaf_multiplier = 1.3
#How big can a leaf be?
var max_leaf_size
var min_leaf_size

#How far away do hallways HAVE to be from each other. Setting this too high will cause the generator to fail as it won't
#be able to make connections
export var hallway_prune = 2

#Chance to split a leaf that is not above the maximum size.
export var split_chance = 25

#How many rooms in the dungeon?
export var min_rooms = 10
export var max_rooms = 25
var num_rooms #The number of rooms picked for this level.

#How big can a room be?
export var min_room_size = 4
export var max_room_size = 7 

#The space to leave from one region to another, this means every room will have at least two spaces between them.
export var leaf_border = 1 

#The tile the map will start covered in.
export var fill_tile = "stone"

#Should we attempt extra connections?
export var extra_connections = true
export var num_extra_connections = 2

export var total_tries = 100 #How many tries to connect the rooms on first pass. If this fails the dungeon will have non-connected rooms, but it will not lock up!
export var tries_least_connection = 10 #How many tries to connect the least-connected room to another, if this fails it will try to make a random connection
export var tries_extra_connection = 30 #How many tries to make making a connection between two random rooms (extra)

export var chance_room_dark = 100

var level
var leafs = [] #All leafs that were created
var regions = [] #All regions created (Rect2)
var rooms = [] #All rooms created 

var map = [] #matrix of Tiles that make up the playing area

var tile_map: TileMap


#Root leaf that will give access to all regions/rooms.
var root 
var free_regions = []

var start_points = []
var end_points = []

var doors = []
var horizontal_halls = []
var vertical_halls = []

func _ready():
	randomize()
	pass
	
func build_level():
	#First create a leaf to be the root of all leafs
	root = Leaf.new()
	leafs.clear()
	regions.clear()
	rooms.clear()
	map.clear()
	free_regions.clear()
	root.initialize(0,0,dungeon_size.x,dungeon_size.y)
	leafs.append(root)
	start_points.clear()
	end_points.clear()
	horizontal_halls.clear()
	vertical_halls.clear()
	doors.clear()
	tile_map = TileMap.new()
	tile_map.tile_set = tile_set
	tile_map.cell_size = Vector2(24,24)
	tile_map.z_index = 0
	
	chance_room_dark = chance_room_dark
	#Use the room size constraints to determine constraints on leaf size. This can be changed to make different types of dungeons.
	#If you don't add in the leaf border the room placement will break.
	min_leaf_size = min_room_size + (leaf_border * 2)
	max_leaf_size = int((max_room_size * max_leaf_multiplier)) + (leaf_border * 2)
	
	#Decide now how many rooms we want
	num_rooms = range(min_rooms,(max_rooms + 1))[randi()%range(min_rooms,(max_rooms + 1)).size()]
	
	#We loop through every leaf in our Vector over and over again until no more leafs can be split.
	#This will give us a collection of leafs (regions) that can be filled with rooms and other dungeon features
	#	with no fear that things will overlap.
	var did_split = true
	while did_split:
		did_split = false
		for l in leafs:
			if l.left_child == null && l.right_child == null:
				#if leaf is too big, or by chance
				if l.width > max_leaf_size || l.height > max_leaf_size || randi()%100 + 1 < split_chance:
					if l.split(min_leaf_size): #Split the leaf!
						#if we did split, push the children to the array.
						leafs.append(l.left_child)
						leafs.append(l.right_child)
						did_split = true
						
	fill_map(fill_tile)
	place_rooms()
	connect_rooms()
	update_map()
	
	#Package up the level to send back.
	level = load("res://src/level_gen/Level.tscn").instance()
	var map_object = Map.new()
	map_object.initialize(map, regions, rooms)
	level.map = map_object
	level.add_child(tile_map)
	print("TileMap Name: " + tile_map.name)
	return level

func place_rooms():
	#Get a list of leafs that we can put rooms in with no risk of overlapping. To do we have to go down from the root leaf.
	find_free_regions(root)
	regions = free_regions.duplicate()
	
	#If we are asked to make more rooms then there are regions we have a couple choices.
	#	1. We can error out and refuse to make the level
	#	2. We can regenerate the leafs and hope to have enough next time
	#	3. We can simply make as many rooms as we can given the leafs we have. (What we do here)
	if num_rooms > free_regions.size():
		num_rooms = free_regions.size()
	
	var rooms_placed = 0
	while rooms_placed < num_rooms:
		#Get a random region
		var region = free_regions[(randi()%free_regions.size()) -1]
		
		#Place a room in it.  If we have room, enlarge the room a random width/height up to the constraints.
		var room_width = min_room_size 
		if region.size.x - (leaf_border *2) > min_room_size:
			var enlarge = randi() % int(region.size.x - (leaf_border * 2) - min_room_size)
			room_width += enlarge
			
		var room_height = min_room_size
		if region.size.y - (leaf_border *2) > min_room_size:
			var enlarge = randi() % int(region.size.y - (leaf_border * 2) - min_room_size)
			room_height += enlarge
		
		#This ensures we don't go over the maximum size for a room.
		room_width = min(room_width, max_room_size)
		room_height = min(room_height, max_room_size)
		
		#Now we have the dimensions it is time to decide where in the leaf to put the room.
		#	First we make sure it leaves the border requested.
		var min_x = region.position.x + leaf_border
		var max_x = region.end.x - (room_width + leaf_border)
		var min_y = region.position.y + leaf_border
		var max_y = region.end.y - (room_height + leaf_border)
		
		var room_x
		var room_y
		
		#This check is here to make sure I don't try and divide by zero.
		if min_x == max_x:
			room_x = min_x
		else:
			room_x = range(min_x, max_x)[randi()%range(min_x, max_x).size()]
		
		if min_y == max_y:
			room_y = min_y
		else:
			room_y = range(min_y, max_y)[randi()%range(min_y, max_y).size()]
		
		#We have everything we need to make and place a room, so let's do it.
		var new_room = Room.new()	
		new_room.init(Rect2(room_x,room_y,room_width,room_height))
		#Decide if the room will be a dark one.
		var darkness = util.rand_int(0,100)
		if darkness < chance_room_dark: new_room.is_dark = true
		rooms.append(new_room)
		rooms_placed = rooms_placed + 1
		
		#This region now has a room in it, so take it out of the line up to avoid overlapping rooms.
		#I could allow overlapping rooms if I wanted to. I'd have to change how doors and other features are 
		#generated so that the pathing worked out.  Also I could no longer trace the pathing from the middle of a room.
		free_regions.erase(region)
#Fills the map with one tile
func fill_map(tile):
	var id = 0
	map.clear()
	var fill_num = int(tile_map.tile_set.find_tile_by_name(tile))
	for x in range(0, dungeon_size.x):
		map.append([])
		for y in range(0, dungeon_size.y):
			map[x].append([])
			var new_tile = Tile.new()
			new_tile.init(fill_num,tile,false,false,false)
			id = id + 1
			new_tile.astar_id = id
			map[x][y] = new_tile

	
#This gets all the free leafs so we can place dungeon features in them without overlapping.  It starts from the leaf given and
	#works down until it has decendants that have no children (leafs that have never been split). 
func find_free_regions(start):
	if start.left_child != null || start.right_child != null:
		#This leaf has been split, so go to its children leafs
		if start.left_child != null:
			find_free_regions(start.left_child)
		if start.right_child != null:
			find_free_regions(start.right_child)
	else:
		free_regions.append(Rect2(start.x,start.y,start.width,start.height))
		
#Use AStar to connect all the rooms together by hallways.	
func connect_rooms():
	var stone_graph = AStar.new()
	var point_id = 0
	var least_tries = 0
	var tries = 0
	#First we build a graph which shows every bit of stone on the map and what pieces of stone it can connect to.
	for x in range(dungeon_size.x):
		for y in range(dungeon_size.y):
			if map[x][y].tile_name == "stone":
				stone_graph.add_point(point_id,Vector3(x,y,0))
				
				#Connect to left if also stone
				if x > 0 && map[x - 1][y].tile_name == "stone":
					var left_point = stone_graph.get_closest_point(Vector3(x - 1,y,0))
					stone_graph.connect_points(point_id, left_point)
					
				#Connect to above if also stone
				if y > 0 && map[x][y - 1].tile_name == "stone":
					var above_point = stone_graph.get_closest_point(Vector3(x, y -1, 0))
					stone_graph.connect_points(point_id, above_point)
					
				point_id += 1
				
	#We need a second graph before we can make the pathways.  This is made up of the center of every room their connections to each other.
	#	For example if a room has no connections then we know there is no pathway to it.
	var room_graph = AStar.new()
	point_id = 0
	for room in rooms:
		var room_center = room.rect.position + room.rect.size /2
		room_graph.add_point(point_id, Vector3(room_center.x, room_center.y,0))
		point_id += 1
	
	#Add connections until every room has a way to get to every other room.
	while !all_rooms_connected(room_graph):
		if least_tries < tries_least_connection:
			if (add_connection(stone_graph, room_graph,true)):
				least_tries = 0
				tries = 0
			else:
				least_tries = least_tries + 1
				tries = tries + 1
		else:
			if (add_connection(stone_graph, room_graph,false)):
				least_tries = 0
				tries = 0
			else:
				tries = tries + 1
		if tries >= total_tries:
			print("Yeah I failed to make the connections. Halp.")
			break		
	
	tries = 0
	if extra_connections:
		var connections_made = 0
		
		while connections_made < num_extra_connections:
			if (add_connection(stone_graph,room_graph,false)):
				connections_made = connections_made + 1
				tries = 0
			else:
				tries = tries + 1
			if tries >= tries_extra_connection:
				break
				print("couldn't make the extra connections.")
				
	

#Can we get from every room to every other room? This is how  we know we can stop making pathways.
func all_rooms_connected(graph):
	var points = graph.get_points()
	var start = points.pop_back()
	for point in points:
		var path = graph.get_point_path(start,point)
		if !path:
			return false
	return true

#Connects the two rooms that are the least connected on the level
func add_connection(stone_graph, room_graph, connect_least):
	
	#Get the least connected rooms we can.
	var start_room_id
	var end_room_id
	var hall_success 
	if connect_least:
		start_room_id = get_least_connected_room(room_graph)
		#end_room_id = util.rand_int(0,rooms.size())
		end_room_id = get_nearest_unconnected_room(room_graph, start_room_id)
	else:
		start_room_id = util.rand_int(0,rooms.size())
		end_room_id = util.rand_int(0,rooms.size())


	#Pick start and end points to make connections between rooms
	#The paths will end in doors (or archways) built into the walls of rooms.
	
	#New Shiney way of getting random spots inside the rooms.
	var start_position = get_random_point_in_room(rooms[start_room_id])
	var end_position = get_random_point_in_room(rooms[end_room_id])
	hall_success = create_halls(Vector2(start_position.x,start_position.y),Vector2(end_position.x,end_position.y))
	
	if hall_success:
		#Update the room graph so we knows these two rooms are now connected.
		room_graph.connect_points(start_room_id, end_room_id)
		return true
	else:
		return false

#Create a hallway between two points
func create_halls(start, end):
	#Now we connect the two rooms together with hallways.  
	#"This looks pretty complicated, but it's just trying to figure out which point is where and then either draw a straight line
	#	or a pair of lines to make a right-angle to connect them" - Tom Hely"
	
	#Rectangles that contain all the hallways.
	var point1 = start
	start_points.append(point1)
	var point2 = end
	end_points.append(point2)
	
	var w = point2.x - point1.x
	var h = point2.y - point1.y
	var hall_h
	var hall_v
	
	if w < 0:
		if h < 0:
			if randf() > 0.5: #decides if we make a hallway vertically or horizontally first
				hall_h =(Rect2(point2.x,point1.y, abs(w),1))
				hall_v =(Rect2(point2.x,point2.y, 1,abs(h)))
			else:
				hall_h =(Rect2(point2.x,point2.y, abs(w)+1, 1))
				hall_v =(Rect2(point1.x,point2.y, 1, abs(h)))
		elif h > 0:
			if randf() > 0.5:
				hall_h =(Rect2(point2.x,point1.y,abs(w),1))
				hall_v =(Rect2(point2.x,point1.y, 1, abs(h)))
			else:
				hall_h =(Rect2(point2.x,point2.y,abs(w)+1,1))
				hall_v =(Rect2(point1.x,point1.y,1,abs(h)))
		elif h == 0:
			hall_h =(Rect2(point2.x,point2.y,abs(w),1))
		
	elif w > 0:
		if h < 0:
			if randf() > 0.5:
				hall_h =(Rect2(point1.x,point2.y,abs(w),1))
				hall_v =(Rect2(point1.x,point2.y,1,abs(h)))
			else:
				hall_h =(Rect2(point1.x,point1.y,abs(w)+1,1))
				hall_v =(Rect2(point2.x,point2.y,1,abs(h)))
		elif h > 0:
			if randf() > 0.5:
				hall_h =(Rect2(point1.x,point1.y,abs(w),1))
				hall_v =(Rect2(point2.x,point1.y,1,abs(h)))
			else:
				hall_h =(Rect2(point1.x,point2.y,abs(w)+1,1))
				hall_v =(Rect2(point1.x,point1.y,1,abs(h)))
		elif h == 0:
			hall_h =(Rect2(point1.x,point1.y,abs(w),1))
	
	elif w == 0:
		if h < 0:
			hall_v =(Rect2(point2.x,point2.y,1,abs(h)))
		else:
			hall_v =(Rect2(point1.x,point1.y,1,abs(h)))
			
	#If you hit the corner of any room 
	for room in rooms:
		for corner in room.corners:
			if hall_v:
				if hall_v.has_point(corner):
					return false
			if hall_h:
				if hall_h.has_point(corner):
					return false
	#If a hallway is right next to another hallway
	if hall_h:
		for hall in horizontal_halls:
			for space in range(1,hallway_prune + 1):
				if hall_h.position.y == hall.position.y - space || hall_h.position.y == hall.position.y + space:
					return false
	if hall_v:
		for hall in vertical_halls:
			for space in range(1,hallway_prune + 1):
				if hall_v.position.x == hall.position.x - space || hall_v.position.x == hall.position.x +space:
					return false
				
				
	if hall_h:
		horizontal_halls.append(hall_h)
	if hall_v:
		vertical_halls.append(hall_v)
	return true

#Count a room's connections to find one that is relatively secluded.
func get_least_connected_room(room_points):
	var point_ids = room_points.get_points()
	var least
	
	for point in point_ids:
		var count = room_points.get_point_connections(point).size()
		if !least || count < least:
			least = count
	return least

func get_nearest_unconnected_room(room_points,target_point):
	var target_position = room_points.get_point_position(target_point)
	var point_ids = room_points.get_points()
	
	var least_distance
	var nearest
	
	for point in point_ids:
		if point == target_point:
			continue
		
		var path = room_points.get_point_path(point, target_point)
		if path:
			continue
		var dist = (room_points.get_point_position(point) - target_position).length()
		if !least_distance || dist < least_distance:
			least_distance = dist
			nearest = point
	return nearest

func make_new_door(room):
	var options = []
	#top and bottom door locations
	for x in range(room.rect.position.x + 1,room.rect.end.x -2):
		options.append(Vector3(x,room.rect.position.y,0))
		options.append(Vector3(x,room.rect.end.y - 1,0))
		
	#left and right door locations
	for y in range(room.rect.position.y + 1, room.rect.end.y - 2):
		options.append(Vector3(room.rect.position.x, y, 0))
		options.append(Vector3(room.rect.end.x - 1, y, 0))
	
	var chosen_spot = options[randi() % options.size()]
	room.doors.append(Vector2(chosen_spot.x,chosen_spot.y))
	return chosen_spot

#Update the tiles on the map so they show the generative work.
func update_map():
	var tile_name
	var tile_num
		#put in edges
	for room in rooms:
				#put in the corners
		tile_name = "room_corner"
		tile_num = int(tile_map.tile_set.find_tile_by_name(tile_name))
		map[room.corners[0].x][room.corners[0].y].init(tile_num,tile_name,false,false,false)
		map[room.corners[1].x][room.corners[1].y].init(tile_num,tile_name,true,false,false)
		map[room.corners[2].x][room.corners[2].y].init(tile_num,tile_name,false,true,false)
		map[room.corners[3].x][room.corners[3].y].init(tile_num,tile_name,true,true,false)
		
		tile_name = "room_wall_top"
		tile_num = int(tile_map.tile_set.find_tile_by_name(tile_name))
		for x in range(room.rect.position.x + 1,room.rect.position.x + room.rect.size.x - 1):
			map[x][room.rect.position.y].init(tile_num,tile_name,false,false,false)
			map[x][room.rect.position.y + room.rect.size.y -1].init(tile_num,tile_name,false,true,false)
		
		tile_name = "room_wall_west"
		tile_num = int(tile_map.tile_set.find_tile_by_name(tile_name))
		for y in range(room.rect.position.y + 1, room.rect.position.y + room.rect.size.y - 1):
			map[room.rect.position.x][y].init(tile_num,tile_name,false,false,false)
			map[room.rect.position.x + room.rect.size.x -1][y].init(tile_num,tile_name,true,false,false)
		
	tile_name = "floor_hall"
	tile_num = int(tile_map.tile_set.find_tile_by_name(tile_name))
	for hall in vertical_halls:
		for x in range(hall.position.x,hall.position.x + hall.size.x):
			for y in range(hall.position.y, hall.position.y + hall.size.y):
					map[x][y].init(tile_num,tile_name,false,false,true)
	
	for hall in horizontal_halls:
		for x in range(hall.position.x,hall.position.x + hall.size.x):
			for y in range(hall.position.y, hall.position.y + hall.size.y):
					map[x][y].init(tile_num,tile_name,false,false,true)
					
	tile_name = "floor"
	tile_num = int(tile_map.tile_set.find_tile_by_name(tile_name))
	#Overwrite inside with the floor of the room.
	for room in rooms:
		for x in range(room.rect.position.x + 1, room.rect.position.x + room.rect.size.x - 1):
			for y in range(room.rect.position.y + 1, room.rect.position.y + room.rect.size.y - 1):
				map[x][y].init(tile_num,tile_name,false,false,true)
	
	#Update the tile_map
	for x in range(0,dungeon_size.x):
		for y in range(0,dungeon_size.y):
			tile_map.set_cell(x,y,map[x][y].tile_num,map[x][y].flip_x,map[x][y].flip_y)
								
		
func get_random_point_in_room(room):
	var x = util.rand_int(room.rect.position.x + 1, room.rect.position.x + room.rect.size.x - 1)
	var y = util.rand_int(room.rect.position.y + 1, room.rect.position.y + room.rect.size.y - 1)
	return Vector2(x,y)	

