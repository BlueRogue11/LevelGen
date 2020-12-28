extends Node2D
class_name Tile
var astar_id = 0 #Set during level generation. Unique among other tiles on a level.
var tile_num = 0
var tile_name = "not initiated"
var flip_x = false
var flip_y = false
var scents = {} #Dictionary of actor keys and integer values showing the scent an actor has left


#Passable by normal means?
var passable = true

#Objects on the tile
var objects = []
#Actor on this tile
var actor : Actor

func init(_tile_num,_tile_name,_flip_x=false,_flip_y=false,_passable=true):
	tile_name = _tile_name
	tile_num = _tile_num
	flip_x = _flip_x
	flip_y = _flip_y
	passable = _passable
	actor = null
	

func _ready():
	pass
