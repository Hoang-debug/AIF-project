extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var collision = CollisionShape3D.new()
	var shape = ConvexPolygonShape3D.new()
	shape.points = $MeshInstance3D.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	collision.shape = shape
	collision.position = position
	add_child(collision)
