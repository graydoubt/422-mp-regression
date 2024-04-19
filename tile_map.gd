extends TileMap



@export var character_scene: PackedScene = preload("res://character.tscn")

@export var player_spawn_points: Node2D

## If enabled, the [member DemoMPCharacter.authority_id] will be set to the client's peer_id, so
## the client can move the character locally.
## If disabled, the server uses the clients' input synchronizer to apply movement server-side.
@export var trust_clients: bool = true

## KV pairs: peer_id => character_node 
var player_characters: Dictionary = {}


func player_joined(peer_id: int) -> void:
	var character: CharacterBody2D = character_scene.instantiate()
	add_child(character, true)
	
	player_characters[peer_id] = character
	character.peer_id = peer_id
	character.authority_id = peer_id if trust_clients else 1
	
	#character.global_position = _select_player_spawn_location()
	if peer_id == 1:
		character.global_position = _select_player_spawn_location(0)
	else:
		character.global_position = _select_player_spawn_location(1)
		character.visible = false
		
		character.make_camera_current.rpc_id(peer_id)
		character.set_start_position.rpc_id(peer_id, character.global_position)


## If a player leaves, drop their stuff and remove them.
func player_left(peer_id: int) -> void:
	var character: CharacterBody2D = player_characters[peer_id]
	remove_child(character)
	character.queue_free()


func _select_player_spawn_location(index: int = -1) -> Vector2:
	var spawn_location: Marker2D
	if index == -1:
		spawn_location = player_spawn_points.get_children().pick_random()
	else:
		spawn_location = player_spawn_points.get_children()[index]
	return spawn_location.global_position
