extends Area2D

var active = false
@onready var room = self.get_parent()
@onready var game = room.get_parent()
@export var type = "north"
# Called when the node enters the scene tree for the first time.

func _on_body_entered(body):
	if get_parent().get_child(0).get_overlapping_bodies().size() == 1:
		active = true
	else:
		active = false
	if (body == game.player && active == true):
#		if game.player.health <= 9*game.player.max_health/10:
#			game.player.health += game.player.max_health/10
#			game.player.healthBar.update(game.player.health)
		game.enterdoor(self)
