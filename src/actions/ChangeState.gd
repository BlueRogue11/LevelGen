#AI uses this to signal it has changed its state and needs to recalculate its action. This action takes no energy.
extends "res://src/actions/Action.gd"

func execute(targets):
	return true
