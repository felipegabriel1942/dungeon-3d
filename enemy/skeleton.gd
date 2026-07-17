extends CharacterBody3D


const SPEED = 2.0
const JUMP_VELOCITY = 4.5

@export var max_hitpoints := 5
@export var attack_range := 3

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var attack_cooldown: Timer = $AttackCooldown

var player
var provoked := false
var aggro_range := 12.0
var is_idle := true
var is_hurt := false
var is_walking := false
var is_dead := false
var is_attacking := false

var hitpoints: int = max_hitpoints:
	set(value):
		hitpoints = value
		
		print(hitpoints)
		
		if hitpoints <= 0:
			is_dead = true
			animation_player.play("Rig_Medium_General/Death_A")
			await get_tree().create_timer(2.0).timeout
			queue_free()
		else:
			is_hurt = true
			animation_player.play("Rig_Medium_General/Hit_A")
		
		#provoked = true

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
func _process(delta: float) -> void:
	navigation_agent_3d.target_position = player.global_position

func _physics_process(delta: float) -> void:
	var next_position = navigation_agent_3d.get_next_path_position()
		
	print(is_hurt, "; ", is_dead, "; ", is_attacking)	
		
	if is_hurt or is_dead or is_attacking:
		return;

	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction = global_position.direction_to(next_position)
	var distance = global_position.distance_to(player.global_position)

	if distance <= aggro_range:
		provoked = true
		
	if provoked:
		if distance <= attack_range:
			if attack_cooldown.is_stopped():
				is_attacking = true
				attack_cooldown.start(3)
				animation_player.play("Rig_Medium_CombatMelee/Melee_1H_Attack_Slice_Diagonal")
			return
		else:
			attack_cooldown.stop()

	if direction:
		look_at_target(direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		animation_player.play("Rig_Medium_MovementBasic/Walking_A")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func take_damage(amount: int) -> void:
	hitpoints -= amount
	
func look_at_target(direction: Vector3) -> void:
	var adjusted_direction = direction
	adjusted_direction.y = 0
	look_at(global_position + adjusted_direction, Vector3.UP, true)

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name.contains("Hit"):
		is_hurt = false
		is_attacking = false
	
	if anim_name.contains("Attack"):
		is_attacking = false
