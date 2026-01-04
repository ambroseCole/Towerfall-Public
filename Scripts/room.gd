extends Node2D

var north_door = load("res://scenes/door.tscn").instantiate()
var south_door = load("res://scenes/door.tscn").instantiate()
var east_door = load("res://scenes/door.tscn").instantiate()
var west_door = load("res://scenes/door.tscn").instantiate()

@export var is_start = false
@export var is_end = false

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	self.visible = true
	'''here. i place the plaver in the center of the grid and add him to the game!!'''
	for door in [north_door, south_door, east_door, west_door]:
		door.visible = false
		door.position = [Vector2(640,60), Vector2(640,1184+16), Vector2(1184+16, 640), Vector2(96-16, 640) ][[north_door, south_door, east_door, west_door].find(door)]
		door.type = ["north", "south", "east", "west"][[north_door,south_door,east_door, west_door].find(door)]
		match [north_door, south_door, east_door, west_door].find(door):
			2:
				door.set_rotation_degrees(90)
			3:
				door.set_rotation_degrees(-90)
			0:
				door.set_rotation_degrees(0)
			1:
				door.set_rotation_degrees(180)
		add_child(door)
	pass # Replace with function body.
	
func _process(delta):
	if is_start or is_end:
		for i in get_children():
			if i.is_in_group("enemies"):
				i.queue_free()
	if is_start:
		$RichTextLabel.visible = true

