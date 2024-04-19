extends MultiplayerSynchronizer

## This synchronizer is solely responsible for sending the character movement
## to the server.


@export var DEBUG: bool = false

## The position is used by the [DemoMPCharacter] to move the character.
@export var target_position: Vector2

## Follow the main synchronizer to match its visibility changes for any peers
@export var sync: MultiplayerSynchronizer

## Only relevant for debugging to see when the [member target_position] changes
## in [method _on_synchronized].
var _tp: Vector2

func _ready() -> void:
	if sync:
		sync.visibility_changed.connect(_on_sync_visibility_changed)
	if owner:
		await owner.ready
	if not public_visibility:
		# server always needs to be able to see, otherwise syncing will stop
		# when the authority is set to the client
		set_visibility_for(MultiplayerPeer.TARGET_PEER_SERVER, true)
	delta_synchronized.connect(_on_synchronized)


func _on_sync_visibility_changed(peer_id: int) -> void:
	var is_visible: bool = sync.get_visibility_for(peer_id)
	if DEBUG: print("%s::_on_sync_visibility_changed(%s) (is_visible %s on peer: %s)" % [
		get_parent(), peer_id, is_visible, multiplayer.get_unique_id()
	])
	set_visibility_for(peer_id, is_visible)


func _on_synchronized() -> void:
	if target_position != _tp:
		_tp = target_position
		if DEBUG: print("%s::_on_synchronized() -> tp: %s on peer %s" % [get_parent(), _tp, multiplayer.get_unique_id()])

