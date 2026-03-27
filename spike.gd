extends StaticBody3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		var player = get_tree().get_first_node_in_group("player")
		player.transform = player.spawn.transform
