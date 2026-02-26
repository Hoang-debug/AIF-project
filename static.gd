extends StaticBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var collision = CollisionShape3D.new()
	var shape = ConcavePolygonShape3D.new()
	shape.data = $MeshInstance3D.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	collision.shape = shape
	add_child(collision)
