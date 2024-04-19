class_name DemoMPCharacter extends CharacterBody2D

## Demo character with limited network visibility
##
## This character demonstrates how to use multiple synchronizers and offers
## two different modes of operation:[br]
## [br]
## - [b]Untrusted client[/b]: The [member input] synchronizer sends input
## to the host, where the [method _process] and [method _physics_process] together
## move the character. This can result in delayed movement for the client
## player.[br]
## - [b]Trusted client[/b]: The movement is handled on the client,
## and the [member motion] synchronizer sends the character location to
## the host (and other clients). The client player movement will be instant
## and lag free, but it is possible for them to cheat by modifying the
## code on the client and move faster or teleport the charater to any location.[br]
## [br]
## Whether the client is trusted is determined by the [member authority_id].



@export var DEBUG: bool = false

## character movement speed in pixels per second
@export var movement_speed: float = 300.0

## Always syncs character properties (this class) from the server to clients.
## This is how [member peer_id] and [member authority_id] are set for all clients.
@export var sync: MultiplayerSynchronizer

## Handles player movement input.
## Authority of the [member input] synchronizer is generally set to the [member peer_id]
## of the client.
@export var input: MultiplayerSynchronizer

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
		velocity = input.direction * movement_speed
		move_and_slide()
		motion.target_position = global_position


## When [member peer_id] or [member authority_id] are modified, the
## [member sync] synchronizer ensures the values make it to all clients.
## This method is then invoked from the property setters to ensure
## the [member input] and [member motion] synchronizers are updated
## accordingly.
func _update_synchronizer_settings() -> void:
	if DEBUG: print("%s::_update_synchronizer_settings() with peer_id: %s and authority_id: %s" % [self, peer_id, authority_id])

	if peer_id:
		input.set_multiplayer_authority(peer_id)
		if multiplayer.is_server():
			sync.set_visibility_for(peer_id, true)

	if authority_id:
		motion.set_multiplayer_authority(authority_id)

	## only have the client send input if authority stays with the server
	if peer_id > 1 and authority_id == 1:
		input.set_visibility_for(1, true)
	else:
		input.set_visibility_for(1, false)
	
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
