extends CharacterBody2D

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var sprite_origin: Node2D = $SpriteOrigin
@onready var animated_sprite_2d: AnimatedSprite2D = $SpriteOrigin/AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox: CollisionShape2D = $CollisionShape2D

const SPEED = 100.0
const JUMP_VELOCITY = -400.0
const ACCEL = 800.0

const MAX_HEALTH: int = 15
var health: int = MAX_HEALTH

const SLIDING_DECEL = 400.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		if health > 0:
			var direction = sign((player.position - position).x)
			if direction:
				velocity.x = move_toward(velocity.x, direction * SPEED, ACCEL * delta)
				sprite_origin.scale.x = -abs(sprite_origin.scale.x) * direction
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, SLIDING_DECEL * delta)

	handle_sprite()

	move_and_slide()

const MAX_HURT_FRAMES = 20
var hurt_frames: int
func handle_sprite() -> void:
	if health <= 0:
		if animated_sprite_2d.animation != "die":
			animated_sprite_2d.play("die")
	elif hurt_frames > 0:
		animated_sprite_2d.play("hurt")
		hurt_frames -= 1
	else:
		animated_sprite_2d.play("run")

const X_KNOCKBACK = 250.0
const Y_KNOCKBACK = -300.0
const X_VARIANCE = 50.0
const Y_VARIANCE = 10.0
func take_damage(bucket: RigidBody2D, damage: int) -> void:
	if hurt_frames > 0: return
	# Knockback
	var dir_knockback = sign(position.x - player.position.x)
	velocity = Vector2(dir_knockback * X_KNOCKBACK, Y_KNOCKBACK)
	velocity += Vector2(
		randf() * X_VARIANCE - (X_VARIANCE / 2.0),
		randf() * Y_VARIANCE - (Y_VARIANCE / 2.0)
	)
	# Decrease health
	health -= damage
	if health <= 0:
		animation_player.play("die")
	else:
		hurt_frames = MAX_HURT_FRAMES
