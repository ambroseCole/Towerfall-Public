extends Button

var upgrade = upgradeClass.new()
@export var buttonIndex = 1
@onready var activateButton = $/root/GameManager
@onready var player = %CharacterBody2D

func _ready():
	activateButton.upgradeActivate.connect(_upgradeActivate)

#Load info from generated upgrade
func _upgradeActivate(upgradeList):
	upgrade = upgradeList[buttonIndex]
	$title.text = upgrade.title + upgrade.extra
	$description.text = upgrade.description
	$icon.texture = load(upgrade.imgpath)
	$title2.text = "[right]"+ upgrade.type.to_upper()

#Give player selected upgrade
func _pressed():
	player.upgradeHandle(upgrade)
	%UpgradeButtonLayer.visible = false
	player.handleInput = true
	activateButton.prevNums.append(upgrade.code)
	get_tree().paused = false
