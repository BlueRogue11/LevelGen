extends CanvasLayer

onready var region_checkbox = $Show_Regions
onready var minimap_checkbox = $Minimap_Checkbox

func _on_Region_Display_region_toggled(onoff):
	region_checkbox.pressed = onoff
	


func _on_Minimap_Display_minimap_toggled(onoff):
	minimap_checkbox.pressed = onoff

func toggle_collision(onoff):
	collision_checkbox.pressed = onoff
