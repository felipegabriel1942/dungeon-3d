extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var mouse_motion := Vector2.ZERO

@export var max_hitpoints := 100

@onready var camera_pivot: Node3D = $CameraPivot
@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var sword: Sword = $CameraPivot/Camera3D/Hand/Sword
@onready var damage_animation_player: AnimationPlayer = $DamageTexture/DamageAnimationPlayer

var hitpoints: int = max_hitpoints:
	set(value):
		if value < hitpoints:
			damage_animation_player.stop()
			damage_animation_player.play("TakeDamage")
		
		hitpoints = value
		
		EventBus.health_changed.emit(value, max_hitpoints)
		
		if hitpoints <= 0:
			get_tree().reload_current_scene()

func _ready() -> void:
	add_to_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	handle_camera_rotation()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_foward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			mouse_motion = -event.relative * 0.001
	
	if Input.is_action_pressed("attack"):
		sword.attack()

func handle_camera_rotation() -> void:
	rotate_y(mouse_motion.x)
	
	camera_pivot.rotate_x(mouse_motion.y)
	camera_pivot.rotation_degrees.x = clampf(
		camera_pivot.rotation_degrees.x, -90.0, 90.0
	)
	
	mouse_motion = Vector2.ZERO

func take_damage(amount: int) -> void:
	hitpoints -= amount
