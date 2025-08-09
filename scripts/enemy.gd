extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -400.0
const ACCEL = 300.0

const MAX_HEALTH: int = 20
var health: int = MAX_HEALTH

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite_origin: Node2D = $SpriteOrigin

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction = sign((player.position - position).x)
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCEL * delta)
		sprite_origin.scale.x = -abs(sprite_origin.scale.x) * direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

const X_KNOCKBACK = 300.0
const Y_KNOCKBACK = -300.0
func take_damage(bucket: RigidBody2D, damage: int) -> void:
	health -= damage
	if health <= 0:
		die()
	else:
		velocity = Vector2(sign(position.x - player.position.x) * X_KNOCKBACK, Y_KNOCKBACK)

func die() -> void:
	queue_free()
