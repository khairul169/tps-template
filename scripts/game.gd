extends Spatial

func _ready():
	pass

func _input(event: InputEvent) -> void:
	if (event is InputEventKey && event.pressed):
		if (event.scancode == KEY_ESCAPE):
			get_tree().quit();
