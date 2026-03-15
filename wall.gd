@tool
extends Node3D

@onready var wall: CollisionShape3D = $StaticBody3D/CollisionShape3D
@export var one_way := false

func _ready() -> void:
	$Area3D/MeshInstance3D.visible = Engine.is_editor_hint()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if not one_way:
		return
		
	if body.is_in_group("player"):
		print("enter")
		wall.disabled = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if not one_way:
		return
		
	if body.is_in_group("player"):
		print("exit")
		wall.disabled = false
