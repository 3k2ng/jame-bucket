extends RigidBody2D

@onready var icon: Sprite2D = $Icon
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var pickup_area: Area2D = $PickupArea

var invuln_frames: int = 10
func _physics_process(delta: float) -> void:
	if invuln_frames:
		invuln_frames -= 1
	
	if invuln_frames > 0:
		icon.modulate = Color.RED
		pickup_area.monitoring = false
	else:
		icon.modulate = Color.ORANGE
		pickup_area.monitoring = true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and invuln_frames <= 0:
		icon.modulate = Color.GREEN
		body.equip_bucket()
		queue_free()
