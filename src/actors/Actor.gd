extends Position2D
class_name Actor
signal died(actor)
signal moved(actor, old_pos, new_pos)
var current_state
export var stats : Resource
onready var drops : = $Drops
onready var sprite = $Sprite
onready var actions = $Actions
onready var bars = $Bars
onready var ai = $AI
onready var status_effects = $StatusEffects
var tile_pos setget tile_pos_set

export var player_controlled : bool = false
export var is_main_character : bool = false
export var display_name : String

func _ready() -> void:
	tile_pos = Vector2(0,0)
	stats = stats.copy()
	stats.connect("health_depleted", self, "_on_health_depleted")
	
func take_damage(hit):
	stats.take_damage(hit) #Probably better to check this when something changes health using set/get
	# prevent playing both stagger and death animation if health <= 0
	if stats.health > 0:
		pass
		
#Modify here how much energy an actor gets.
func give_energy(energy):
	stats.energy = stats.energy + energy
	
func _on_health_depleted():
	yield(print("I'm dead"), "completed")
	emit_signal("died", self)
	
func tile_pos_set(value):
	emit_signal("moved", self, tile_pos, value)
	tile_pos = value
	self.position = self.tile_pos * 24

	
#Update my state at the start of my turn.
func start_turn():
	pass

#Update my state at the end of my turn.
func end_turn():
	pass

