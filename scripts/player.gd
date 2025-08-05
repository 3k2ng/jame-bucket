extends CharacterBody2D

enum State {
	ON_BUCKET, OFF_BUCKET
}
var state: State

var facing: int = 1

var input_vector = Vector2(0, 0)

@onready var on_animated_sprite_2d: AnimatedSprite2D = $OnAnimatedSprite2D
@onready var on_collision_shape_2d: CollisionShape2D = $OnCollisionShape2D
@onready var off_animated_sprite_2d: AnimatedSprite2D = $OffAnimatedSprite2D
@onready var off_collision_shape_2d: CollisionShape2D = $OffCollisionShape2D

func _ready() -> void:
	update_state(State.OFF_BUCKET)
	

func _physics_process(delta: float) -> void:
	match state:
		State.ON_BUCKET:
			handle_on_bucket(delta)
		State.OFF_BUCKET:
			handle_off_bucket(delta)

	handle_input(delta)

	move_and_slide()


func handle_input(delta: float) -> void:
	var direction := Input.get_axis("left", "right")
	facing = sign(direction) if sign(direction) else facing
	input_vector = Input.get_vector("left", "right", "up", "down")

	if Input.is_action_just_pressed("kick") and state == State.ON_BUCKET and not is_on_wall():
		kick_bucket()
		


const BUCKET_MAX_SPEED = 500.0
const ACCEL = 1000.0
const BUCKET_JUMP_VELOCITY = -320.0
const BUCKET_GRAVITY = Vector2(0.0, 700.0)
func handle_on_bucket(delta: float) -> void:
	if not is_on_floor():
		velocity += BUCKET_GRAVITY * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = BUCKET_JUMP_VELOCITY
	if Input.is_action_just_released("jump") and not is_on_floor():
		velocity.y = max(velocity.y, 0.0)

	var direction := Input.get_axis("left", "right")
	velocity.x = move_toward(velocity.x, (direction if direction else 0.0) * BUCKET_MAX_SPEED, ACCEL * delta)

const MAX_SPEED = 200.0
const JUMP_VELOCITY = -200.0
const GRAVITY = Vector2(0.0, 1000.0)
func handle_off_bucket(delta: float) -> void:
	if not is_on_floor():
		velocity += GRAVITY * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_released("jump") and not is_on_floor():
		velocity.y = max(velocity.y, 0.0)

	var direction := Input.get_axis("left", "right")
	velocity.x = (direction if direction else 0.0) * MAX_SPEED


const BUCKET = preload("res://scenes/bucket.tscn")
var BUCKET_FORCE = 1500.0
var BUCKET_Y_FORCE = 1.5
var BUCKET_Y_BASE = 50.0
var BUCKET_SPAWN_OFFSET = 0.0
func kick_bucket() -> void:
	if state == State.OFF_BUCKET: return
	var new_bucket = BUCKET.instantiate()
	if input_vector == Vector2.ZERO: new_bucket.linear_velocity.x = facing * BUCKET_FORCE
	else: new_bucket.linear_velocity = input_vector * BUCKET_FORCE
	new_bucket.position = position + Vector2(facing * BUCKET_SPAWN_OFFSET, 0.0)
	get_parent().add_child(new_bucket)
	update_state(State.OFF_BUCKET)

func equip_bucket() -> void:
	update_state(State.ON_BUCKET)

func update_state(new_state: State) -> void:
	state = new_state
	on_animated_sprite_2d.visible = state == State.ON_BUCKET
	on_collision_shape_2d.disabled = not state == State.ON_BUCKET
	off_animated_sprite_2d.visible = not state == State.ON_BUCKET
	off_collision_shape_2d.disabled = state == State.ON_BUCKET
