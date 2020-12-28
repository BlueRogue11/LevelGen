extends CanvasLayer
onready var mini_map = $Minimap_Tilemap

# Called when the node enters the scene tree for the first time.
var map

func _ready():
	pass	

func initialize(level : Level):
	level.connect("hero_arrived",self,"on_hero_entered_level")	
	map = level.map
					
func update_point(index : Vector2):
	if map.point_in_bounds(index):
		var tile = map.get_tile(index)
		if tile.passable: 
				set_point_floor(index)
		else: set_point_unexplored(index)
				
		if tile.actor:
			if tile.actor.is_main_character:
				set_point_hero(index)
			else:
				set_point_monster(index)


func set_point_monster(index):
	mini_map.set_cell(index.x,index.y,mini_map.tile_set.find_tile_by_name("enemy"))
	
func set_point_floor(index):
	mini_map.set_cell(index.x,index.y,mini_map.tile_set.find_tile_by_name("floor"))
	
func set_point_unexplored(index):
	mini_map.set_cell(index.x,index.y,-1)

func set_point_hero(index):
	mini_map.set_cell(index.x,index.y,mini_map.tile_set.find_tile_by_name("player"))


func on_hero_entered_level(hero):
	hero.get_node("AI").connect("toggle_minimap",self,"_on_toggle_minimap_display")

func set_area_unexplored(rect):
	for x in range(rect.position.x,rect.position.x + rect.size.x):
		for y in range(rect.position.y,rect.position.y + rect.size.y):
			set_point_unexplored(Vector2(x,y))
				
func _on_toggle_minimap_display():
	if !mini_map.visible:
		mini_map.show()
	else:
		mini_map.hide()

func set_area_visible(rect):
	for x in range(rect.position.x,rect.position.x + rect.size.x):
		for y in range(rect.position.y,rect.position.y + rect.size.y):
			update_point(Vector2(x,y))
				
func set_radius_visible(index,num):
	set_area_visible(Rect2(index.x - num, index.y - num,num*2 + 1,num*2 + 1))
	

