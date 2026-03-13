extends StaticBody3D


var first = false
var second = false
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_first_area_entered(area: Area3D) -> void:
	first = true


func _on_first_area_exited(area: Area3D) -> void:
	pass # Replace with function body.



func _on_check_area_entered(area: Area3D) -> void:
	pass # Replace with function body.


func _on_check_area_exited(area: Area3D) -> void:
	pass # Replace with function body.
