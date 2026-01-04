extends Area2D

@onready var player = %CharacterBody2D
var charas = load("res://Dialog/NoOne.dch")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_body_entered(body):
	print_debug("yay")
	if body == player:
		var layout = Dialogic.start('Tooltip')
		layout.register_character(charas,self)
		player.isInShrine = true
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass




func _on_body_exited(body):
	if body == player: 
		Dialogic.end_timeline()
		player.isInShrine = false
