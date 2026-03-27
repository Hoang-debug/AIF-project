@tool
extends Node3D

@onready var wall: CollisionShape3D = $StaticBody3D/CollisionShape3D
@export var one_way := false

func _ready() -> void:
	# Will screw up the level if in engine
	if !Engine.is_editor_hint():
		$MeshInstance3D.mesh = $MeshInstance3D.mesh.duplicate()
		wall.shape = wall.shape.duplicate()
		$Area3D/MeshInstance3D.mesh = $Area3D/MeshInstance3D.mesh.duplicate()
		$Area3D/CollisionShape3D.shape = $Area3D/CollisionShape3D.shape.duplicate()
		set_size()
		scale = Vector3(1,1,1)
	
	$Area3D/MeshInstance3D.visible = false
	#if !one_way:
		#$Area3D/MeshInstance3D.visible = false

func set_size():
	$MeshInstance3D.mesh.size = scale
	wall.shape.size = scale
	$Area3D/MeshInstance3D.mesh.size = scale
	$Area3D/CollisionShape3D.shape.size = scale
	
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if not one_way:
		return
		
	if not body.is_in_group("player") and not body.is_in_group("grabbable"):
		return

	var wall_forward = global_transform.basis.z.normalized()
	var to_body = (body.global_position - global_position).normalized()

	var dot = wall_forward.dot(to_body)

	# Only allow from one side
	if dot > 0:
		print("Allowed side → disable wall")
		wall.disabled = true
	else:
		print("Blocked side → keep wall solid")


func _on_area_3d_body_exited(body: Node3D) -> void:
	if not one_way:
		return
		
	if not body.is_in_group("player") and not body.is_in_group("grabbable"):
		return

	# Small delay prevents flicker/sticking
	await get_tree().create_timer(0.1).timeout
	wall.disabled = false
		
