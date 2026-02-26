extends CharacterBody3D

# Player setting
@export_category("Movement")
@export var SPEED: float = 5.0
@export var JUMP_VELOCITY = 4.5

# Camera setting
@export_category("Camera")
@export var mouse_sensitivity := 0.003
var camera_rotation := 0.0
var mouse_captured := true

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("paused"):
		mouse_captured = !mouse_captured
		Input.set_mouse_mode(
			Input.MOUSE_MODE_CAPTURED if mouse_captured else Input.MOUSE_MODE_VISIBLE
		)
	
	if !mouse_captured:
		return
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera_rotation -= event.relative.y * mouse_sensitivity
		camera_rotation = clamp(camera_rotation, deg_to_rad(-90), deg_to_rad(90))
		$Camera3D.rotation.x = camera_rotation
		
func _physics_process(delta: float) -> void:
	if !mouse_captured:
		return
		
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("grabable"):
		set_collision_layer(1)
		set_collision_mask_value(1,false)
		set_collision_mask_value(2,true)


func _on_area_3d_body_exited(body: Node3D) -> void:
	set_collision_layer(2)
	set_collision_mask_value(1,true)
	set_collision_mask_value(2,false)
