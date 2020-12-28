#Waiting takes up the remaining of the actor's turn.
extends "res://src/actions/Action.gd"

func execute(targets):
	#Use up all remaining energy.
	if get_parent().get_parent().stats.energy >= 0: 
		self.energy_cost = get_parent().get_parent().stats.energy
	else:
		self.energy_cost = 0
	return true
