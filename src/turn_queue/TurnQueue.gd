extends Node2D

class_name TurnQueue

var active_actor
export var energy_per_tick = 1000
signal round_end

var turn_start = 0

func _ready():
	get_parent().connect("new_actor",self,"add_actor")
	get_parent().connect("hero_arrived",self,"add_hero")
	self.connect("round_end",self,"end_round")

func end_round():
	give_energy()

func add_hero(hero):
	add_actor(hero)
	active_actor = hero
	
func add_actor(actor):
	add_child(actor)

#Give all the actors some energy
func give_energy():
	for actor in get_actors():
		actor.give_energy(energy_per_tick)

func clear_energy():
	for actor in get_actors():
		actor.stats.energy = 0
	
#Makes the active user preform the action specified.
#The action is attempted, and if it fails it does not move the turn until an action is selected.
#If the action succeeded then the action cost is deducted from the actor's energy pool.
#If they can go again, the actor remains active, If they can't, the queue moves to the next actor.
#One actor has the "player main" tag, which means that on the end of their turn all actors are given energy and the global turn counter 
#goes up by one.
func preform_action(action):
	var preformed = false
	
	if active_actor.stats.energy > 0:
		preformed = action.execute(get_parent())
	if preformed:

		#Deduct cost of the action from the actor's energy.
		active_actor.stats.energy = active_actor.stats.energy - action.energy_cost 
		
		#If the actor is out of energy, their turn is over.
		if active_actor.stats.energy <= 0:
			active_actor.end_turn()
			if active_actor.is_main_character:
				emit_signal("round_end")
			next_actor()
		#Otherwise the same actor will go again.

#Get the next actor that can take a turn.
func next_actor():
	while true:
		var next_actor_index : int = (active_actor.get_index() + 1) % get_child_count()
		active_actor = get_child(next_actor_index)
		if active_actor.stats.energy > 0: break
		else:
			active_actor.start_turn()
			active_actor.end_turn()
	#Apply status effects on active player
	if active_actor.player_controlled:
		active_actor.get_node("Sprite/Camera2D").current = true
	active_actor.start_turn()
	
func get_actors() -> Array:
	return get_children()
			
func player_controlled_actors():
	var player_controlled = []
	for actor in get_actors():
		if actor.get_node("AI").player_controlled == true:
			player_controlled.append(actor)
	return player_controlled
	
func print_queue():
	#Prints the actors' currently in the queue
	var string : String
	for actor in get_children():
		string += actor.name
	print(string)
