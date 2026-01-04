extends Button

@export var resumeStart = "start"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _pressed():
	match resumeStart:
		"resume":
			get_tree().paused = false
			get_parent().get_parent().visible = false
		"start":
			get_tree().paused = true
			get_parent().get_parent().visible = false
			var _dialog = Dialogic.start('beginning')
			await Dialogic.timeline_ended
			get_tree().paused = false
			get_tree().change_scene_to_file("res://Scenes/PlayerScene.tscn")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
