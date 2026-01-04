extends CharacterBody2D

@export var SPEED = 700.0
@export var current_room = []
@onready var camera = $GridSnapper/PlayerCamera
#@onready var collision = $CollisionShape2D


func _physics_process(_delta):
	handle_movement()

func handle_movement():
	var dirx = Input.get_axis("ui_left","ui_right")
	var diry = Input. get_axis("ui_down", "ui_up")
	if dirx: 
		velocity.x = dirx * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0,SPEED)
	if diry:
		velocity.y = -diry * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	move_and_slide()

func setSPEED(newValue):
	print_debug(newValue)

func align_camera(room):
	print(get_window().size)
	print(get_viewport_rect().size)
	#get_window().size = Vector2i(672, 672)
	var vect_pos = room[2]
	var rm = room[0]
	var ref_pos = room[1]
	
	print(camera.get_parent().position)
	camera.get_parent().position.y = vect_pos.y+640
	camera.get_parent().position.x = vect_pos.x+640
	camera.get_parent().set_as_top_level(true)
	
	
	#want to switch parents, find position, and switch back to the player as the parent
	
