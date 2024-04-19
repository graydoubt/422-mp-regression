extends MultiplayerSynchronizer

## Syncs the direction from client to server

var direction: Vector2


func _process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")


