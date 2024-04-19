class_name GGNetworkScopedObject2D extends Area2D

## A scoped object is made visible to a network peer, if its
## [GGNetworkClientScope2D] overlaps with it.
##
## Scoped objects are scenes that are intended to be visible to a
## client over the network.
## The heavy lifting is done by Godot Engine's [MultiplayerSpawner] and
## [MultiplayerSynchronizer].[br]
## [br]
## The [member object_strategy] determines what happens when a network object
## is "within scope" of a client.
## Often it just means that a [MultiplayerSpawner]'s visibility for that client
## is toggled, as is the case with the [GGNetworkObjectSyncStrategy].


@export var synchronizer: MultiplayerSynchronizer

## If enabled, objects will be invisible for the local/host player
@export var hide_objects_for_local_player: bool = true


func _ready():
	if not multiplayer.is_server():
		return
	if owner:
		await owner.ready
	monitorable = true


func enter_scope(scope: GGNetworkClientScope2D):
	if scope.peer_id > 1:
		synchronizer.set_visibility_for(scope.peer_id, true)
	elif hide_objects_for_local_player:
		owner.visible = true


func exit_scope(scope: GGNetworkClientScope2D):
	if scope.peer_id > 1:
		synchronizer.set_visibility_for(scope.peer_id, false)
	elif hide_objects_for_local_player:
		if owner:
			owner.visible = false
