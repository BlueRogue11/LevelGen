extends Node
class_name util
enum d {UP,DOWN,LEFT,RIGHT,UPLEFT,UPRIGHT,DOWNLEFT,DOWNRIGHT}
const NULL_POSITION = Vector2(-1,-1)
const dirs = [	
				Vector2(0,-1), 
				Vector2(0,1),
				Vector2(-1,0),
				Vector2(1,0),
				Vector2(-1,-1),
				Vector2(1,-1),
				Vector2(-1,1),
				Vector2(1,1)
			]
#Returns a random integer. Max excluded.
static func rand_int(minimum,excluded_max):
	if minimum == excluded_max:
		print("random_integer: Minimum value same as max, returning minimum: " + String(minimum))
		return minimum
	elif excluded_max < minimum:
		print ("random_integer: Invalid min/max. Max is higher then min. GERT FFUFCKED")
		return null
	else:
		var r = range(minimum, excluded_max)[randi()%range(minimum, excluded_max).size()]
		return r

static func rand_dir():
	return dirs[rand_int(0,dirs.size())]

static func move_rand(position : Vector2):
	return position + rand_dir()

#Move a position in a direction
static func move_up(position : Vector2):
	return position + Vector2(0,-1)

static func move_down(position : Vector2):
	return position + Vector2(0,1)

static func move_left(position : Vector2):
	return position + Vector2(-1,0)

static func move_right(position : Vector2):
	return position + Vector2(1,0)

static func move_upleft(position : Vector2):
	return position + Vector2(-1,-1)

static func move_upright(position : Vector2):
	return position + Vector2(1,-1)

static func move_downleft(position : Vector2):
	return position + Vector2(-1,1)

static func move_downright(position : Vector2):
	return position + Vector2(1,1)

static func get_rect_around_point(point,radius):
	var x = point.x
	var y = point.y
	return Rect2(x - radius, y - radius,radius*2 + 1,radius*2 + 1)

static func points_touching(point1,point2):
	var area = get_rect_around_point(point1,1)
	if area.has_point(point2):
		return true
	return false
	
static func get_tiles_around(map,point):
	var points = get_points_around(point)
	
	var tiles = []
	for point in points:
		if point.x in range(map.size()) && point.y in range(0,map[0].size()):
			tiles.append(map[point.x][point.y])
	return tiles
	
static func get_points_around(point):
	var points = []
	points.append(move_up(point))
	points.append(move_down(point))
	points.append(move_left(point))
	points.append(move_right(point))
	points.append(move_upleft(point))
	points.append(move_upright(point))
	points.append(move_downleft(point))
	points.append(move_downright(point))
	return points

	
