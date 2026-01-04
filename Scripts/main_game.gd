extends Node2D
#instantiating important global variables

@onready var player = get_node("/root/Node2D/CharacterBody2D")
@export var positionDict = {}
@export var level = 1
@export var enemy = preload("res://enemy_one.tscn")
@export var enemy1 = preload("res://enemy_two.tscn")
@export var enemy2 = preload("res://enemy_three.tscn")
@export var room1 = preload("res://Scenes/room.tscn")
@export var room2 = preload("res://Scenes/room2.tscn")
@export var room3 = preload("res://Scenes/room3.tscn")
@export var floor = 1
'''dictionary containing positions of all possible rooms 
this is used to place rooms together-evenly-inside a node
---------------------------------------------------------
this dictionary uses a number system to assign rooms 
that looks something like the following:
	1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
	11| 12| 13| 14| 15| 16| 17| 18| 19
	21| 22| 23| 24| 25| 26| 27| 28| 29
	etc.
---------------------------------------------------------
this allows accessing and sorting rooms much easier:
	1. to find adjacent rooms below & right, add 10 and 1
	2. to find adjacent rooms above & left, subtract 10 and 1
	3. since rooms never have zeroes, there is no need to code 
	for rooms ending in 1 or 9

this list is essential to the placement and creation of rooms
IT WOULD BE HIGHLY IDEAL FOR THIS TO GET REMOVED (FOR LARGER LEVELS)
'''

@export var rooms = []
'''list used to hold refrences to the nodes of individual rooms'''

@export var rmpos = []
'''list containing Vector2 positions of rooms, correspondent to "rooms"'''

@export var rmnums = []
'''list containing the reference number of rooms, correspondent to "rooms" 
and "rmnums"'''

@export var start_room = {}
'''dict that holds a reference to a designated starting room and its 
reference number'''

@export var end_room = {}
'''dict that holds a reference to a designated ending/boss room and its 
reference number'''

func _ready():
	'''variable defines the number of rooms to be created'''
	var room_num = 11 + (floor * 3)
	
	'''for loop adds all the possible positions of rooms to the position dictionary'''
	for y in range(-4,room_num*2+-5):
		'''1. outside for loop iterates over nums that define y values'''
		
		for x in range(-4,5):
			'''2. inside for loop iterates over nums that define x values'''
			
			positionDict[int(str(y+4)+str(x+5))] = Vector2(x*640*2,y*640*2)
			'''3. set the key to a reference number and the value attached
			to its corresponding Vector2 position'''
		
	while true:
		setup_rooms(room_num, [5,1])
		position_doors()
		assign_special_rooms()
		var er = int(end_room.keys()[0])
		var sr = int(start_room.keys()[0])
		if er == sr:
			pass
		elif (er%10 == 9 and er in [sr+1, sr+2, sr+10, sr+20, sr-10, sr-20, sr-9, sr+11]):
			pass
		elif (er%10 == 8 and er in [sr+1, sr+2, sr+10, sr+20, sr-10, sr-20, sr-9, sr+11]):
			pass
		elif (er%10 == 2 and er in [sr+1, sr+2, sr+10, sr+20, sr-10, sr-20, sr-9, sr+11]):
			pass
		elif (er%10 == 1 and er in [sr+1, sr+2, sr+10, sr+20, sr-10, sr-20, sr-9, sr+11]):
			pass
		else:
			break
		rooms = []
		start_room = {}
		end_room = {}
		rmnums = []
		rmpos = []
	'''run functions to setup rooms'''
		
	return

func setup_rooms(num_rms=7, rm_density=[0,0]):
	'''
	- function takes two parameters: number of rooms to be created and
	density of the rooms when combined
	- the density of rooms is a two value list with a numerator and
	denominator
	- room density controls the amount of rooms that are connected to rooms
	with and have 3+ room connections
	'''
	
	var cur_rm_num = 0
	'''variable used to hold the reference number of the room being focused on'''
	
	var counter = 0
	'''
	- variable used to count the number of times the random room generator 
	iterates without assigning a new room
	- prevents errors
	'''
	
	print("began to determine rooms")
	
	'''The following logic is used to generate rooms and add their elements to
	the lists "rooms", "rmnums", and "rmpos", then add these rooms to the MainGame
	Node'''
	while num_rms>len(rmpos):
		if len(rmpos) == 0:
			rmpos.append(positionDict[((num_rms-1)*10)+5])
			rmnums.append(((num_rms-1)*10)+5)
			make_room(rmpos[len(rmpos)-1])
		else:
			cur_rm_num = rmnums[len(rmnums)-1]
			for value in [cur_rm_num+1,cur_rm_num-1\
			,cur_rm_num+10,cur_rm_num-10]:
				if value in positionDict.keys():
					if value not in rmnums \
					and check_neighbors_filled(value,rm_density) <= 1 \
					and num_rms > len(rmpos) and chance_coin() == 1:
						rmpos.append(positionDict[value])
						rmnums.append(value)
						make_room(rmpos[len(rmpos)-1])
			
			if cur_rm_num == rmnums[len(rmnums)-1]:
				counter += 1
				if counter > 10:
					print("counter exceeded: likely error \
					 found.")
					for value in [cur_rm_num+1,cur_rm_num-1\
			,cur_rm_num+10,cur_rm_num-10]:
						if value not in rmnums \
					and value in positionDict.keys() \
					and check_neighbors_filled(value,rm_density) <= 1 \
					and num_rms > len(rmpos):
							print("room finally found")
							rmpos.append(positionDict[value])
							rmnums.append(value)
							make_room(rmpos[len(rmpos)-1])
							break
				if cur_rm_num == rmnums[len(rmnums)-1] && counter > 10:
					print("no rooms could be assigned: restarting generation")
					rmnums = []
					rmpos = []
					rooms = []
					for child in self.get_children():
						self.remove_child(child)
					setup_rooms(num_rms, rm_density)
					break
					print("finished determining rooms")
					return
	print("finished determining rooms")

func position_doors():
	var pos = 0
	for room in rooms:
		pos = rmnums[rooms.find(room)]
		for value in [pos+1,pos-1,pos+10,pos-10]:
			if value in rmnums:
				[room.east_door, room.west_door, room.south_door, room.north_door]\
			[[pos+1,pos-1,pos+10,pos-10].find(value)].visible = true

func assign_special_rooms():
	'''function determines the start and end rooms'''
	
	var has_one_door = false
	var indx = 0
	
	'''takes the first end room and makes it the starting room by iterating
	through rmnums until finding a room where check_neighbors_filled returns 
	false'''
	while not has_one_door:
		if indx < len(rmnums):
			if check_neighbors_filled(rmnums[indx], [1,0]) == 1:
				has_one_door = true
			else:
				indx += 1
		else:
			break
		print(rmnums[indx])
	if has_one_door:
		start_room[rmnums[indx]] = rooms[indx]
		rooms[indx].is_start = true
	else:
		while not has_one_door:
			if indx < len(rmnums):
				if check_neighbors_filled(rmnums[indx], [1,0]) == 2:
					has_one_door = true
				else:
					indx += 1
			else:
				break
		print(rmnums[indx])
	
	if has_one_door:
		start_room[rmnums[indx]] = rooms[indx]
		rooms[indx].is_start = true
	
	player.position = Vector2(positionDict[start_room.keys()[0]].x+320*2,positionDict[start_room.keys()[0]].y+320*2)
		
	
	'''reverses the lists rooms and rmnums so the same method above can 
	be applied in finding the end room'''
	rmnums.reverse()
	rooms.reverse()
	
	indx = 0
	has_one_door = false
	
	while not has_one_door:
		if indx < len(rmnums):
			if check_neighbors_filled(rmnums[indx], [1,0]) == 1:
				has_one_door = true
			else:
				indx += 1
		else:
			break
	if has_one_door:
		end_room[rmnums[indx]] = rooms[indx]
		rooms[indx].is_end = true
	
	'''place these jawns back to normal'''
	rmnums.reverse()
	rooms.reverse()

func chance_coin():
	'''simulates coin flp, returns 1 or 2'''
	return [1,2].pick_random()

func check_neighbors_filled(pos: int, chance: Array):
	'''function takes the reference position of a room and an array
	with room density to rrturn the number of neighbors a room has'''
	
	var num_filled = 0
	
	'''loop finds all rooms adjacent to room at the position'''
	for value in [pos+1,pos-1,pos+10,pos-10]:
		if value in rmnums:
			num_filled += 1
			
	var num = round(chance[0])
	var denom = round(chance[1])
	
	'''if the array chance represents a feaction > 0, we use a
	list filled with -1's and other numbers to simulate a chance program
	this allows the room density to be modified based on "chance"'''
	if denom > 0 and num >= 0:
		var chance_list = []
		for i in range(denom):
			if chance_list.count(num) < num:
				chance_list.append(num)
			else:
				chance_list.append(-1)
				
		chance_list.shuffle()
		if chance_list[0] == num:
			num_filled = 0
	return num_filled

func make_room(pos: Vector2):
	'''takes a pos and creates a room at pos'''
	var node = room3.instantiate()
	match floor:
		1:
			node = room1.instantiate()
		2:
			node = room2.instantiate()
		3:
			node = room3.instantiate()
	node.position = pos
	add_child(node)
	rooms.append(node)
	var range
	if player.chosenGod == "war":
		range = randi_range(3,7)
	else:
		range = randi_range(2,5)
	for i in range(range):
		var currentenemy
		var spawnthing = randi_range(0,floor-1)
		match spawnthing:
			0:
				currentenemy = enemy.instantiate()
			1:
				currentenemy = enemy1.instantiate()
			2:
				currentenemy = enemy2.instantiate()
		node.add_child(currentenemy)
		currentenemy.add_to_group("enemies")
		currentenemy.position.x += randf_range(-300,300)
		currentenemy.position.y += randf_range(-300,300)
		while currentenemy.get_child(4).get_overlapping_bodies().size() >= 1:
			currentenemy.position.x += randf_range(-30,3)
			currentenemy.position.y += randf_range(-30,30)
	
func enterdoor(door):
	'''runs when player touches a door in a room: if door is active
	it allows the player to pass to another room'''
	match door.type:
		"east":
			if door.visible:
				player.position.x += 227*2
				player.visible = false
		"west":
			if door.visible:
				player.position.x -= 227*2
				player.visible = false
		"south":
			if door.visible:
				player.position.y += 227*2
				player.visible = false
		"north":
			if door.visible:
				player.position.y -= 227*2
				player.visible = false
	
