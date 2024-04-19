class_name GGNetworkClientScope2D extends Area2D


## This is the peer_id of the client, for which the visibility
## of a scoped object will be set.
var peer_id: int = -1:
	set(value):
		peer_id = value
		if is_inside_tree():
			_apply_scope()


## Scope logic only runs server-side
func _ready():
	if not multiplayer.is_server():
		return
	_connect_signals()
	if owner:
		await owner.ready
	monitoring = true


func _connect_signals():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


## Called when the [member peer_id] is set, which may be after
## [method _on_area_entered] already triggered.
## So we're re-forcing it to run again with the [member peer_id] now set.
func _apply_scope():
	if not multiplayer.is_server():
		return
	for area: Area2D in get_overlapping_areas():
		_on_area_entered(area)


func _on_area_entered(area: GGNetworkScopedObject2D):
	if peer_id == -1:
		return
	area.enter_scope(self)


func _on_area_exited(area: GGNetworkScopedObject2D):
	if peer_id == -1:
		return
	if (
		peer_id > 1
		and not multiplayer.get_peers().has(peer_id)
	):
		# visibility changes also when client has disconnected, in which case
		# the peer_id is gone, and set_visibility_for() would result in an error
		return
	area.exit_scope(self)
