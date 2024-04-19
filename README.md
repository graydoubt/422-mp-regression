## Godot Engine 4.2.2 Multiplayer Regression

This multiplayer demo works with Godot 4.2.1, but not with 4.2.2.

Each character has a "client scope" Area2D to detect when another character (or another object) enters its network visibility range.
The "scoped object" node will set the object's `sync` `MultiplayerSynchronizer` visibility according to the "client scope"'s peer_id.


## Multiple MultiplayerSynchronizers

Each character has two `MultiplayerSynchronizer`s.

The "Sync" `MultiplayerSynchronizer` authority is always the server so that the character's `peer_id` and `authority_id` properties can be synced to clients.

The "Motion" `MultiplayerSynchronizer` authority is the client.
The node syncs its own `target_position` property to the server, where it is used to move/lerp the character.

## Bug reproduction

I recommend enabling `Visible Collision Shapes` from the Godot Editor Debug menu.

To reproduce:

- Launch 2 instances of Godot.
- Press `Host` on the first instance
- Press `Join` on the second instance

Use `WASD` to move the player characters.

The first time characters enter each other's visibility range, it works as expected.

Once they leave the range, and re-enter it, the server's character will be stuck at position 0,0.
It seems the client can no longer receive data from the server's Motion synchronizer.
The client will report error messages for each synchronization update:

```
E 0:00:21:0159   get_cached_object: ID 3 not found in cache of peer 1.
  <C++ Error>    Parameter "oid" is null.
  <C++ Source>   modules/multiplayer/scene_cache_interface.cpp:278 @ get_cached_object()
```

and

```
E 0:00:21:0167   on_delta_receive: Ignoring delta for non-authority or invalid synchronizer.
  <C++ Error>    Condition "true" is true. Continuing.
  <C++ Source>   modules/multiplayer/scene_replication_interface.cpp:783 @ on_delta_receive()
```

Possibly related to:

- Godot [PR 87190](https://github.com/godotengine/godot/pull/87190): [MP] Handle cleanup of "scene cache" nodes