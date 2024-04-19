class_name GGNetworkScopedObject2D extends Area2D

## A scoped object is made visible to a network peer, if its
## [GGNetworkClientScope2D] overlaps with it.

@export var synchronizer: MultiplayerSynchronizer


func _ready():
	if not multiplayer.is_server():
		return
	if owner:
		await owner.ready
	monitorable = true


func enter_scope(scope: GGNetworkClientScope2D):
	if scope.peer_id > 1:
		synchronizer.set_visibility_for(scope.peer_id, true)


func exit_scope(scope: GGNetworkClientScope2D):
	if scope.peer_id > 1:
		synchronizer.set_visibility_for(scope.peer_id, false)
