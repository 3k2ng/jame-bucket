extends RigidBody2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var pickup_area: Area2D = $PickupArea

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var player = get_tree().get_first_node_in_group("player")

var damage: int = 5

var invuln_frames: int = 1
var BUCKET_RETURN_FORCE = 2000.0

func _ready() -> void:
	contact_monitor = true

var roll_frames: int

func _physics_process(delta: float) -> void:
	if invuln_frames:
		invuln_frames -= 1
	if invuln_frames > 0:
		pickup_area.monitoring = false
	else:
		pickup_area.monitoring = true

	if len(get_colliding_bodies()) > 0:
		roll_frames = 8
	if roll_frames:
		animated_sprite_2d.play("roll")
		roll_frames -= 1
	else:
		animated_sprite_2d.play("air")

	if Input.is_action_pressed("suck"):
		linear_velocity += (player.position - position).normalized() * BUCKET_RETURN_FORCE * delta
		#collision_shape_2d.disabled = true
	#else:
		#collision_shape_2d.disabled = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and invuln_frames <= 0:
		body.equip_bucket()
		queue_free()
	elif body.is_in_group("enemy") and body.health > 0 and body.hurt_frames <= 0 and linear_velocity.length() > 300.0:
		body.take_damage(self, damage)
		linear_velocity = (player.position - position).normalized() * linear_velocity.length()
