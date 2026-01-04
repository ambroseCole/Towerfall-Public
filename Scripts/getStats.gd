extends RichTextLabel

@onready var activateButton = $/root/GameManager
@onready var player = %CharacterBody2D
# Called when the node enters the scene tree for the first time.
func _ready():
	activateButton.upgradeActivate.connect(_upgradeActivate)

func _upgradeActivate(_upgradeList):
	text = "\nMax Health: " + str(int(round(player.max_health))) + "%\n\n"
	text += "Speed: " + str(int(round(player.speed/7.5))) + "%\n\n"
	text += "Attack Damage: " + str(int(round(player.damage*100))) + "%\n\n"
	text += "Attack Speed: " + str(int(round(player.attackSpeed*100))) + "%\n\n"
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
