extends RigidBody2D

@onready var icon: Sprite2D = $Icon
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var pickup_area: Area2D = $PickupArea

var invuln_frames: int = 1
var BUCKET_RETURN_FORCE = 100.0
func _physics_process(delta: float) -> void:
	if invuln_frames:
		invuln_frames -= 1

	if invuln_frames > 0:
		pickup_area.monitoring = false
	else:
		pickup_area.monitoring = true

	var player = get_tree().get_first_node_in_group("player")
	linear_velocity += (player.position - position) / BUCKET_RETURN_FORCE

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and invuln_frames <= 0:
		body.equip_bucket()
		queue_free()

func _on_player_suck(body: Node2D) -> void:
	if body.is_in_group("player") and invuln_frames <= 0:
		print("suck acquired")
		icon.modulate = Color.GREEN
		body.equip_bucket()
		queue_free()
