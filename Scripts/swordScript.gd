extends Area2D

@onready var player = get_parent().get_parent()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace withx function body.

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.health -= player.damage
		var timer = Timer.new()
		add_child(timer)
		timer.start(0.2)
		var color = body.modulate
		if body:
			body.modulate = Color("ff0000")
		await timer.timeout
		if body:
			body.modulate = color
		timer.queue_free()
		if body.health <= 0:
			body.onDie(true)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


