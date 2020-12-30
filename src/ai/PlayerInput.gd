#PlayerInput turns control over to the player until an action is picked.
extends AITemplate
var get_player_input = false
signal got_player_action
signal toggle_minimap
signal toggle_region
signal toggle_visibility

func choose_action(r_level):
	level = r_level
	get_player_input = true
	#level.room_actor_is_in(me)
	yield(self,"got_player_action")
	yield(get_tree(), "idle_frame")
	return action
	
func _input(event):
	var new_pos = Vector2(-1,-1)
	if get_player_input && level.get_active_actor() == me:
		if !event.is_pressed():
			return
		if event.is_action("Left"):
			new_pos = util.move_left(me.tile_pos)
		elif event.is_action("UpLeft"):
			new_pos = util.move_upleft(me.tile_pos)
		elif event.is_action("DownLeft"):
			new_pos = util.move_downleft(me.tile_pos)
		elif event.is_action("Right"):
			new_pos = util.move_right(me.tile_pos)
		elif event.is_action("UpRight"):
			new_pos = util.move_upright(me.tile_pos)
		elif event.is_action("DownRight"):
			new_pos = util.move_downright(me.tile_pos)
		elif event.is_action("Up"):
			new_pos = util.move_up(me.tile_pos)
		elif event.is_action("Down"):
			new_pos = util.move_down(me.tile_pos)
		elif event.is_action("Wait"):
			get_player_input = false
			action = me.get_node("Actions/Wait")
			emit_signal("got_player_action")
		
		if !new_pos == Vector2(-1,-1):
			action = get_parent().get_node("Actions/Walk")
			action.new_pos = new_pos
			get_player_input = false
			emit_signal("got_player_action")
			# if me.stats.ghost_walk:
				# # if !level.pathfinder.actor_at_location(new_pos):
				# get_player_input = false
				# emit_signal("got_player_action")
			# elif level.pathfinder.is_free(new_pos):
					# get_player_input = false
					# emit_signal("got_player_action")
			
				
				
		elif event.is_action("Minimap_Toggle"):
			emit_signal("toggle_minimap")
	
		elif event.is_action("Collision_Toggle"):
			me.stats.ghost_walk = !me.stats.ghost_walk
		
		elif event.is_action("Region_Toggle"):
			emit_signal("toggle_region")
			
		elif event.is_action("Visibility_Calc_Toggle"):
			print("Hit visibility")
			emit_signal("toggle_visibility")


	
