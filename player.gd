extends CharacterBody3D

# Player setting
@export_group("Movement")
@export var SPEED: float = 5.0
@export var JUMP_VELOCITY = 4.5
@export var SPRINT_AMOUNT: float = 1.5
@export var SNEAK_AMOUNT: float = 0.75

# Camera setting
@export_group("Camera")
@onready var camera = $Camera3D
@export var mouse_sensitivity := 0.003
var camera_rotation := 0.0
var mouse_captured := true

# Object
@export_group("Objects")
@export var throwForce = 7.5
@export var followSpeed = 5.0
@export var followDistance = 2.5
@export var maxDistanceFromCamera = 5.0

# Ray
@onready var interactRay = $Camera3D/InteractRay
var heldObject: RigidBody3D

# Spawn
var spawn: Node3D
var is_resetting := false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_spawn()
	self.transform = spawn.transform

func get_spawn():
	spawn = get_tree().get_first_node_in_group("spawn")

func _physics_process(delta: float) -> void:
	handle_holding_objects()
			
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var current_speed = SPEED

	if Input.is_action_pressed("sprint") and is_on_floor():
		current_speed *= SPRINT_AMOUNT
	if Input.is_action_pressed("sneak") and is_on_floor():
		current_speed *= SNEAK_AMOUNT

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		
		if body.is_in_group("lava") and not is_resetting:
			is_resetting = true
			call_deferred("reset_level")
			#global_position = spawn.global_position

func reset_level():
	get_tree().reload_current_scene()

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
		camera.rotation.x = camera_rotation

# Handle Object 
func set_held_object(body):
	if body and body.is_in_group("grabbable"):
		if body is RigidBody3D:
			heldObject = body

func drop_held_object():
	heldObject = null
	
func throw_held_object():
	var obj = heldObject
	drop_held_object()
	obj.apply_central_impulse(-camera.global_basis.z * throwForce * 10)

func handle_holding_objects():
	# Throwing Objects
	if Input.is_action_just_pressed("throw"):
		if heldObject != null: throw_held_object()
		
	# Dropping / Grabbing Objects
	if Input.is_action_just_pressed("interact"):
		if heldObject != null:
			drop_held_object()
		elif interactRay.is_colliding():
			var body = interactRay.get_collider()
			
			if body.is_in_group("grabbable"):
				set_held_object(body)
			elif body.get_parent() and body.get_parent().is_in_group("grabbable"):
				set_held_object(body.get_parent())
		
	# Object Following
	if heldObject != null:
		var targetPos = camera.global_transform.origin + (camera.global_basis * Vector3(0, 0, -followDistance)) # 2.5 units in front of camera
		var objectPos = heldObject.global_transform.origin # Held object position
		heldObject.linear_velocity = (targetPos - objectPos) * followSpeed # Our desired position
		
		# Drop the object if it's too far away from the camera
		if heldObject.global_position.distance_to(camera.global_position) > maxDistanceFromCamera:
			drop_held_object()

# Handle collision
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("grabbable"):
		set_collision_layer(1)
		set_collision_mask_value(1,false)
		set_collision_mask_value(2,true)


func _on_area_3d_body_exited(body: Node3D) -> void:
	set_collision_layer(2)
	set_collision_mask_value(1,true)
	set_collision_mask_value(2,false)
