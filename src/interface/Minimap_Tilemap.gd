extends TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_point_floor(x,y):
	set_cell(x,y,tile_set.find_tile_by_name("floor"))
	
func set_point_unexplored(x,y):
	set_cell(x,y,-1)

func set_point_hero(x,y):
	set_cell(x,y,tile_set.find_tile_by_name("player"))
	
func set_area_visible(rect,map):
	for x in range(rect.position.x,rect.position.x + rect.size.x):
		for y in range(rect.position.y,rect.position.y + rect.size.y):
			if x < 0 || y < 0 || x > map.size() - 1 || y > map[0].size() -1:
				pass
			else:
				if map[x][y].passable: set_point_floor(x,y)

func set_radius_visible(x,y,num,map):
	set_area_visible(Rect2(x - num, y - num,num*2 + 1,num*2 + 1),map)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
