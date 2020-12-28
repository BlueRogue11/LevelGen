#RandomWalker picks a random location and attempts to walk there. If it isn't possible the actor waits out their turn.
extends AITemplate

func choose_action(level):
	action = null
	
	#print("My tile pos: " + String(me.tile_pos))
	var new_pos = util.move_rand(me.tile_pos)
	#print("I want to move: " + String(new_pos))
	if me.stats.ghost_walk:
		if !level.actor_at_location(new_pos):
			get_parent().get_node("Actions").get_node("Walk").new_pos = new_pos
			action = get_parent().get_node("Actions").get_node("Walk")
	elif level.walkable_location(new_pos):
		get_parent().get_node("Actions").get_node("Walk").new_pos = new_pos
		action = get_parent().get_node("Actions").get_node("Walk")

	if !action : action = get_parent().get_node("Actions").get_node("Wait")	
	yield(get_tree(), "idle_frame")
	return action
	
	
