extends MultiplayerSynchronizer

## Only syncs the character's peer_id and authority_id from server to clients

func _ready() -> void:
	if owner:
		await owner.ready
	if not public_visibility:
		set_visibility_for(MultiplayerPeer.TARGET_PEER_SERVER, true)
