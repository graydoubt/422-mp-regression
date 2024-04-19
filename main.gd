extends Node2D

@export var main_menu: CanvasLayer
@export var host_button: Button
@export var join_button: Button

@export var tilemap: TileMap

func _ready() -> void:
	_connect_menu_buttons()
	_connect_network_signals()


func start_server() -> void:
	var multiplayer_peer := WebSocketMultiplayerPeer.new()
	multiplayer_peer.create_server(5150, "127.0.0.1")
	multiplayer.multiplayer_peer = multiplayer_peer
	tilemap.player_joined(1)


func join_server() -> void:
	var multiplayer_peer := WebSocketMultiplayerPeer.new()
	multiplayer_peer.create_client("ws://127.0.0.1:5150")
	multiplayer.multiplayer_peer = multiplayer_peer


#region Menu

func _connect_menu_buttons() -> void:
	if host_button:
		host_button.pressed.connect(_on_host_button_pressed)
	if join_button:
		join_button.pressed.connect(_on_join_button_pressed)


func _on_host_button_pressed() -> void:
	start_server()
	
	main_menu.hide()
	tilemap.show()


func _on_join_button_pressed() -> void:
	join_server()
	
	main_menu.hide()
	tilemap.show()


#endregion

#region Network

func _connect_network_signals() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)


func _on_peer_connected(peer_id: int) -> void:
	if (
		not multiplayer.is_server()
		or peer_id == 1
	):
		return
	tilemap.player_joined(peer_id)


func _on_peer_disconnected(peer_id: int) -> void:
	if (
		not multiplayer.is_server()
		or peer_id == 1
	):
		return
	tilemap.player_left(peer_id)


func _on_connected_to_server() -> void:
	main_menu.hide()
	tilemap.show()


func _on_server_disconnected() -> void:
	main_menu.show()
	tilemap.hide()


func _on_connection_failed() -> void:
	main_menu.show()
	tilemap.hide()

#endregion
