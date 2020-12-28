extends Object
class_name Leaf
var Leaf = load("res://src/level_gen/Leaf.tscn") # Will load when parsing the script.

#Size and position of the leaf
var x 
var y
var width
var height

#The leaf's children
var left_child
var right_child

#The room inside this leaf
var room

func _ready():
	pass

func initialize(pos_x,pos_y,w,h):
	x = pos_x
	y = pos_y
	width = w
	height = h

func split(min_leaf_size):
	#Begin splitting the leaf into two children.
	if left_child !=null || right_child != null:
		print("Already split , aborting!")
		return false #We already split this leaf, abort!
	
	#Determine the direction of the split 
	#If the width is > 25% larger than height, we split vertically
	#If the height is > 25% larger then the width, we split horizontally
	#Otherwise we split randomly.
	var split_h = randf() > .5;
	if (width > height && (float(width) / float(height) > 1.25)):
		split_h = false
	elif (height > width && (float(height) /float(width) > 1.25)):
		split_h = true
	
	#Can't find how or if Godot uses the ? operator	
	var maximum
	if split_h:
		maximum = height - min_leaf_size
	else:
		maximum = width - min_leaf_size
	
	if maximum <= min_leaf_size:
		return false #leaf is too small to split anymore
	
	var split = range(min_leaf_size,(maximum + 1))[randi()%range(min_leaf_size,(maximum + 1)).size()]
	left_child = Leaf.instance()
	right_child = Leaf.instance()
	
	#Create our left and right children based on the direction of the split.
	if split_h:
		left_child.initialize(x, y, width, split)
		right_child.initialize(x, y + split, width, height - split)
	else:
		left_child.initialize(x,y,split,height)
		right_child.initialize(x + split, y, width - split, height)	
	return true
	

		
				

		
	
	
	
	
	

	

