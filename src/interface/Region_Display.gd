extends Node2D
var show_regions = false
var regions = []
signal region_toggled(onoff)

#This uses pixels to draw so I need the size of the pixels to show the regions correctly.
export var tile_size = 24
export var color = Color.red

func _ready():
	get_parent().connect("new_player_actor",self,"_on_new_player_actor")
	pass # Replace with function body.
	
func _draw():
	if regions.size() > 0:
		for region in regions:
			var pos_x = region.position.x * tile_size
			var pos_y = region.position.y * tile_size
			var width = region.size.x * tile_size
			var height = region.size.y * tile_size
			draw_rect(Rect2(pos_x,pos_y,width,height),color,false)


func _on_toggle_region_display():
	self.visible = !self.visible
	emit_signal("region_toggled",self.visible)

func _on_new_player_actor(actor : Actor):
	actor.get_node("AI").connect("toggle_region",self,"_on_toggle_region_display")