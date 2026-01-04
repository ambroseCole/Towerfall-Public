extends Area2D

@onready var room = self.get_parent()
@onready var game = self.get_parent().get_parent()
@onready var player = game.player
var maingame = preload("res://Scenes/main_game.tscn")
@onready var congrats = get_node("/root/Node2D/Camera2D/Control5")

func _ready():
	if not room.is_start:
		room.visible = false
	if room.is_end:
		print_debug("JFJEJFJF")

func _on_body_entered(body):
	var indx = -1
	if body == player:
		room.visible = true
		indx = game.rooms.find(room)
		player.current_room = [game.rooms[indx],game.rmnums[indx],game.rmpos[indx]]
		player.align_camera(player.current_room)
		player.visible = true
		if get_parent().is_end and get_parent().visible:
			player.health = player.max_health
			player.healthBar.update(player.health)
			call_deferred("rebop")
			

func _on_body_exited(body):
	if body == player:
		room.visible = false
		
func rebop():
	if room.get_parent().floor < 3:
		maingame = maingame.instantiate()
		maingame.floor = room.get_parent().floor + 1
		room.get_parent().get_parent().add_child(maingame)
		room.get_parent().queue_free()
	else:
		congrats.visible = true
		player.queue_free()
#		get_tree().paused = true
		
