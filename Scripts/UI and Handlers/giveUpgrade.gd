extends Node



@onready var gameManager = get_node("/root/GameManager")

func _ready():
	pass # Replace with function body.

#Generate 3 upgrades
func _pressed():
	gameManager.giveUpgrade()
