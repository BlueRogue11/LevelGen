#ToDO
#Make this safe in case map dimensions change.
extends TileMap

var dungeon_x
var dungeon_y
var map 
var map_area
var actor
var minimap
signal area_visible(area)
signal area_fow(area)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#Visibility map is initialized with the level it is on and the actor that it is tracking
func initialize(p_level,p_actor,p_minimap):
	map = p_level.map 
	map_area = Rect2(0,0,map.dimensions.x,map.dimensions.y)
	actor = p_actor
	minimap = p_minimap
	minimap.initialize(p_level)
	dungeon_x = map.dimensions.x
	dungeon_y = map.dimensions.y
	
	erase_visibility()
	actor.get_node("AI").connect("toggle_visibility",self,"_on_toggle_visibility")
	actor.connect("moved",self,"_on_actor_moved")
	_on_actor_moved(actor,Vector2(-1,-1),actor.tile_pos)
	
func _on_toggle_visibility():
	
	if self.visible:
		self.hide()
		minimap.set_area_visible(map_area)
	else:
		self.show()
		set_area_unexplored(map_area)
		minimap.set_area_unexplored(map_area)
		_on_actor_moved(actor,Vector2(-1,-1),actor.tile_pos)
		
func _on_actor_moved(p_actor,old_pos,new_pos):
	var in_lit_room
	#Update the minimap visibility
	#Make the old the player was in part of the fog of war.
	if !(old_pos.x == -1) && !(old_pos.y == -1):
		in_lit_room = false
		for room in map.rooms:
			if room.rect.has_point(old_pos):
				if !room.is_dark:
					set_area_fow(room.rect)
					in_lit_room = true
		#Hallways are easier..
		#if !(in_lit_room): 
		if map_area.has_point(Vector2(old_pos.x,old_pos.y)):
			set_radius_fow(old_pos.x,old_pos.y,1)
	
	in_lit_room = false
	#We can change this to check to see if a room is lit or not
	for room in map.rooms:
		if room.rect.has_point(new_pos):
			if !room.is_dark:
				in_lit_room = true
				set_area_visible(room.rect)
				set_radius_visible(new_pos.x,new_pos.y,1)
				
	#Other cases, for now just turning it on around the player no matter what... this radius can be changed if the player has say, dark vision.
	if !in_lit_room:
		set_radius_visible(new_pos.x,new_pos.y,1)
	minimap.set_point_hero(new_pos)
	minimap.update_point(new_pos)

func erase_visibility():
	for x in range(0,dungeon_x):
		for y in range(0,dungeon_y):
			set_point_unexplored(x,y)

func set_area_fow(rect):
	for x in range(rect.position.x,rect.position.x + rect.size.x):
		for y in range(rect.position.y,rect.position.y + rect.size.y):
			set_point_fow(x,y)
	emit_signal("area_fow", rect)
			
func set_radius_fow(x,y,num):
	set_area_fow(Rect2(x - num, y - num,num*2 + 1,num*2 + 1))
	
func set_area_visible(rect):
	for x in range(rect.position.x,rect.position.x + rect.size.x):
		for y in range(rect.position.y,rect.position.y + rect.size.y):
			set_point_visible(x,y)
			minimap.update_point(Vector2(x,y))
	emit_signal("area_visible", rect)
			
func set_area_unexplored(rect):
	for x in range(rect.position.x,rect.position.x + rect.size.x):
		for y in range(rect.position.y,rect.position.y + rect.size.y):
			set_point_unexplored(x,y)
			
func set_point_fow(x,y):
#	if map.valid_location(Vector2(x,y)):
	set_cell(x,y,1)
	
func set_point_visible(x,y):
#	if map.valid_location(Vector2(x,y)):
	set_cell(x,y,-1)

func set_point_unexplored(x,y):
	set_cell(x,y,0)

func set_radius_visible(x,y,num):
	set_area_visible(Rect2(x - num, y - num,num*2 + 1,num*2 + 1))
	
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
