#DoNothing actors wait out every turn.
extends AITemplate

func choose_action(level):
	var action = get_parent().get_node("Actions").get_node("Wait")
	yield(get_tree(), "idle_frame")
	return action
	