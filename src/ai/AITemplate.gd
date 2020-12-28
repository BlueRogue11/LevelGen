extends Node
class_name AITemplate
var util = preload("res://util.gd")
var me
var action
var level
var rest_chance

#State Machine properties

var action_log = {}
#Time to stay in state if nothing changes -1 = Forever
export var time_to_hibernate : int = -1
export var time_to_waunder : int = -1 
export var time_to_sight_track : int = -1
export var time_to_scent_track : int = 5
export var time_to_attack : int = -1


enum States{
		HIBERNATE, #Stays still until something of interest happens
		WAUNDER,	#Picks a clear spot on the map to walk to
		SIGHT_TRACK,	#Is actively following an actor by sight
		SCENT_TRACK, #Is actively following an actor's scent
		MELEE_ATTACK, #Is attacking a target in range
		}
		
const State_String =[
		"HIBERNATE",
		"WAUNDER",
		"SIGHT_TRACK",
		"SCENT_TRACK",
		"MELLE_ATTACK",
		]
#Action Log enum so I can quickly found out how many turns the AI has been in a state, and the max to be in that state.
enum Mem_Var{
		TURNS_SPENT,
		MAX_TURNS,
		}
var state_memory
var mystate = States.HIBERNATE
		
func _ready():
	me = get_parent()
	#Construct the action log
	action_log[States.HIBERNATE] = [0,time_to_hibernate]
	action_log[States.WAUNDER] = [0,time_to_waunder]
	action_log[States.SIGHT_TRACK] = [0,time_to_sight_track]
	action_log[States.SCENT_TRACK] = [0,time_to_scent_track]
	action_log[States.MELEE_ATTACK] = [0,time_to_attack]
	
	rest_chance = 0
	
func initialize(r_level : Level):
	pass

func i_can_see(target, level):
	return level.actor_can_see(me, target)
	
func choose_action(level: Level):
	"""
	Select an action to perform in combat
	Can be based on state of the actor
	"""
	pass
	
func choose_target(actor : Actor, action : Action, actors : Array = []):
	"""
	Chooses a target to perform an action on
	"""
	pass
