extends Panel

@onready var texto = $RichTextLabel
@onready var texte = $RichTextLabel2
@export var ability = false
@export var index = 0
@onready var player = get_node("/root/Node2D/CharacterBody2D")
func _ready():
	pass # Replace with function body.

func activate(newIndex):
	visible = true
	index = newIndex
	match index:
		0:
			texto.text = "[center]"+ InputMap.action_get_events("ability 1")[0].as_text().trim_suffix(" (Physical)")
		1:
			texto.text = "[center]"+ InputMap.action_get_events("ability 2")[0].as_text().trim_suffix(" (Physical)")
		2:
			texto.text = "[center]"+ InputMap.action_get_events("ultimate")[0].as_text().trim_suffix(" (Physical)")
	texte.text =  "[center]" +player.abilities[newIndex].short


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
