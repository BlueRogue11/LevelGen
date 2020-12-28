#The message box will have to keep track of what is currently in the message box. I believe it will be smart to keep the messagebox
#buffer brief, perhaps 12 lines.
extends CanvasLayer
onready var msgcontrol = $Label

func _ready():
	pass

func clear():
	msgcontrol.clear()

func add_line(line : String):
	msgcontrol.append_bbcode(line)

		
