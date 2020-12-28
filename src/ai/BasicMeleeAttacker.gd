extends AITemplate

var enemy: Actor #who I'm after after.

var path 

var alert = false #Have I seen an enemy on this floor?

var where_last_saw_enemy : Vector2

var old_state #What state I was on last.

func _ready():
	print("IM READY")
	old_state = States.HIBERNATE
	switch_state(States.WAUNDER)
	rest_chance = -1 #Chance I'll rest while waundering.S
	
func choose_action(level: Level) -> Action:
	action = null
	match mystate:
		States.HIBERNATE: action = hibernate(level)
		States.WAUNDER: action = waunder(level)
		States.SIGHT_TRACK: action = sight_track(level)
		States.SCENT_TRACK: action = scent_track(level)
		States.MELEE_ATTACK: action = melee_attack(level)
		
	yield(get_tree(), "idle_frame")
	if action == null:
		print(String(me.display_name) + ": Something went wrong and I didn't pick an action. Going to wait.")
		action = me.get_node("Actions/Wait")

	return action

func hibernate(level : Level) -> Action:
	print("I'm Hibernating.")
	for actor in level.get_visible_actors(me):
		if actor.is_main_character:
			alert = true
			enemy = actor
			where_last_saw_enemy = actor.tile_pos	
			action = switch_state(States.SIGHT_TRACK)
			return action
	return me.get_node("Actions/Wait")


func waunder(level : Level) -> Action:
#	print("Waundering..")
	for actor in level.get_visible_actors(me):
		if actor.is_main_character:
			alert = true
			enemy = actor
			where_last_saw_enemy = actor.tile_pos	
			action = switch_state(States.SIGHT_TRACK)
			return action
	
	#Pick a new location to go
	if !path:
		var goal_position = level.random_location_in_room(level.random_room())
		path = level.pathfinder.get_best_path(me.tile_pos,goal_position)
		
	elif path && path.size() > 0:
		if(util.rand_int(0,10) >= rest_chance):
			var walk_to = path.pop_front()
			if level.pathfinder.is_free(walk_to):
				me.get_node("Actions/Walk").new_pos = walk_to
				return me.get_node("Actions/Walk")
			else:
				switch_state(States.WAUNDER) #Something got in our way, recalculate
	
	#Done or failed path or I'm just taking a breather.
	return me.get_node("Actions/Wait")

			
#Track a player by sight.  No timeout on this state currently.
#Can this be moved elsewhere? func i_can_see() Target in sight function?
func sight_track(level : Level) -> Action:	
	
	if in_melee_range(enemy,level):  #Make this function general and in pathfinder?
		return switch_state(States.MELEE_ATTACK)
	
	if i_can_see(enemy, level):
		if !(enemy.tile_pos == where_last_saw_enemy): #enemy moved so get new path.
			where_last_saw_enemy = enemy.tile_pos
#			print("Enemy not where she was.")
			return switch_state(States.SIGHT_TRACK)
		
#		if !path || path.size() < 1 : path = level.pathfinder.get_best_path(me.tile_pos,where_last_saw_enemy,true)
			
		if path && path.size() > 0:
			var walk_to = path.pop_front()
			if level.pathfinder.is_free(walk_to):
#				print("Trying to walk.")
				me.get_node("Actions/Walk").new_pos = walk_to
				return me.get_node("Actions/Walk")
			else: 
#				print("Recalculating.")
				return switch_state(States.SIGHT_TRACK) #Something got in our way, recalculate.
	else:
		return switch_state(States.SCENT_TRACK)
			
	return me.get_node("Actions/Wait")
	
	
				
func scent_track(level : Level) -> Action:
	if i_can_see(enemy,level): return switch_state(States.SIGHT_TRACK)
	if state_timeout(States.SCENT_TRACK): return switch_state(States.WAUNDER)
	
	var smelliest_pos = Vector2(-1,-1) #(-1,-1) is an impossible position.
	
	var contenders_for_smelliest = level.pathfinder.get_surrounding_free(me.tile_pos)
	
	if contenders_for_smelliest.size() > 0:
		for point in contenders_for_smelliest:
			if level.map[point.x][point.y].scents.has(enemy):
				if smelliest_pos == Vector2(-1,-1): 
					smelliest_pos = point
				else:
					if level.map[point.x][point.y].scents[enemy] > level.map[smelliest_pos.x][smelliest_pos.y].scents[enemy]: 
						smelliest_pos = point
	
	if !(smelliest_pos == Vector2(-1,-1)):
		increment_state_timer(States.SCENT_TRACK)
		me.get_node("Actions").get_node("Walk").new_pos = smelliest_pos
		return me.get_node("Actions").get_node("Walk")
	
	#I can't smell my target anymore, going to waunder around
	return switch_state(States.WAUNDER)
	
	
func melee_attack(level: Level):
	if in_melee_range(enemy,level):
		print(me.display_name + ": I'm attacking " + enemy.display_name + ". Rawr!") #Yeah no combat system yet ;)
		where_last_saw_enemy = enemy.tile_pos
		return me.get_node("Actions/MeleeAttack")
	else:
		return switch_state(States.SIGHT_TRACK)

	return null

func in_melee_range(target, level : Level):
	if util.points_touching(me.tile_pos,target.tile_pos):
			return true
	
#Switch to a new state and let the engine know I am doing that.
func switch_state(state) -> Action:
	path = null
	old_state = mystate
	action_log[mystate][Mem_Var.TURNS_SPENT] = 0 #Reset the old state's counter.
#	print(me.display_name + ": switching to: " + State_String[mystate])
#	print(me.display_name + ": switching to: " + String(mystate))
	mystate = state
	return me.get_node("Actions/SwitchStates")
	
		
func state_timeout(state) -> bool:
	var max_turns = action_log[state][Mem_Var.MAX_TURNS]
	if max_turns == -1: return false # -1 means no timeout to this state.
	if action_log[state][Mem_Var.TURNS_SPENT] >= max_turns: return true
	return false

func increment_state_timer(state) -> void:
	action_log[state][Mem_Var.TURNS_SPENT] = action_log[state][Mem_Var.TURNS_SPENT] + 1
