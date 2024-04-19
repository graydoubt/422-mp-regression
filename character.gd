class_name DemoMPCharacter extends CharacterBody2D

## Demo character with limited network visibility


@export var DEBUG: bool = false

## character movement speed in pixels per second
@export var movement_speed: float = 300.0

## Always syncs character properties (this class) from the server to clients.
## This is how [member peer_id] and [member authority_id] are set for all clients.
@export var sync: MultiplayerSynchronizer


## Syncs the character position.
## The direction of the sync depends on the [member authority_id].
@export var motion: MultiplayerSynchronizer


@export var scope: Area2D

@export var label: Label

@export var sprite: Sprite2D

@export var min_warp_distance: float = 50
@export_range(0, 1, 0.1) var movement_lerp: float = 0.33

## The id of the peer that owns this character
var peer_id: int = 0:
	set(value):
		peer_id = value
		scope.peer_id = value
		_update_synchronizer_settings()

## The id of the authority that moves this character
var authority_id: int = 0:
	set(value):
		authority_id = value
		_update_synchronizer_settings()


## Handles movement by lerping or warping towards the [member target_position]'s
## [code]target_position[/code].
func _process(_delta: float) -> void:
	if (
		not motion.is_multiplayer_authority()
		and motion.target_position
	):
		if global_position.distance_to(motion.target_position) > min_warp_distance:
			global_position = motion.target_position
		else:
			global_position = global_position.lerp(motion.target_position, movement_lerp)


## Uses the direction from the [member input] and moves the character.
func _physics_process(_delta: float) -> void:
	if motion.is_multiplayer_authority():
		var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = direction * movement_speed
		move_and_slide()
		motion.target_position = global_position


## When [member peer_id] or [member authority_id] are modified, the
## [member sync] synchronizer ensures the values make it to all clients to invoke this setter
func _update_synchronizer_settings() -> void:
	if DEBUG: print("%s::_update_synchronizer_settings() with peer_id: %s and authority_id: %s" % [self, peer_id, authority_id])

	if peer_id and multiplayer.is_server():
		# main sync always visible to client
		sync.set_visibility_for(peer_id, true)

	if authority_id:
		motion.set_multiplayer_authority(authority_id)
	
	if label:
		label.text = "peer_id: %d\nauthority_id: %d" % [peer_id, authority_id]


@rpc("authority", "call_remote", "reliable")
func make_camera_current() -> void:
	$Camera2D.make_current()


@rpc("authority", "call_remote", "reliable")
func set_start_position(g_position: Vector2) -> void:
	if DEBUG: print("%s::set_start_position(%s)" % [self, g_position])
	global_position = g_position
	motion.target_position = g_position
