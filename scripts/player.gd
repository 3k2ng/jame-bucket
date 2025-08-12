extends CharacterBody2D

enum State {
	ON_BUCKET, OFF_BUCKET
}
var state: State

var facing: int = 1
var direction: float
var input_vector: Vector2

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var on_collision_shape_2d: CollisionShape2D = $OnCollisionShape2D
@onready var off_collision_shape_2d: CollisionShape2D = $OffCollisionShape2D

func _ready() -> void:
	update_state(State.OFF_BUCKET)
	# obv get rid of these later
	Global.double_jump = true
	Global.suck_bucket = true

func _physics_process(delta: float) -> void:
	match state:
		State.ON_BUCKET:
			handle_on_bucket(delta)
		State.OFF_BUCKET:
			handle_off_bucket(delta)

	handle_input(delta)

	handle_sprite(delta)

	move_and_slide()


const BUCKET_MAX_SPEED = 650.0
const ACCEL = 1000.0
const BUCKET_JUMP_VELOCITY = -500.0
const DOUBLE_JUMP_VELOCITY = -400.0
func handle_input(delta: float) -> void:
	direction = Input.get_axis("left", "right")
	facing = sign(direction) if sign(direction) else facing
	input_vector = Input.get_vector("left", "right", "up", "down")

	if Input.is_action_just_pressed("kick") and state == State.ON_BUCKET:
		kick_bucket()

	if Global.double_jump and Input.is_action_just_pressed("jump") and state == State.ON_BUCKET and not is_on_floor():
		double_jump()
		velocity.y = DOUBLE_JUMP_VELOCITY

const BUCKET_TURN_AROUND = 3.0
const BUCKET_DASH_FORCE = 1000.0
func handle_on_bucket(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = BUCKET_JUMP_VELOCITY
	if Input.is_action_just_released("jump") and not is_on_floor():
		velocity.y = max(velocity.y, 0.0)

	var v_to = (direction if direction else 0.0) * BUCKET_MAX_SPEED
	var v_delta = ACCEL * delta * (BUCKET_TURN_AROUND if sign(direction) != sign(velocity.x) else 1.0)
	velocity.x = move_toward(velocity.x, v_to, v_delta)

	if Input.is_action_just_pressed("dash"):
		velocity.x += BUCKET_DASH_FORCE

const MAX_SPEED = 300.0
const JUMP_VELOCITY = -300.0
const DECEL = 300.0
func handle_off_bucket(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_released("jump") and not is_on_floor():
		velocity.y = max(velocity.y, 0.0)

	if not is_on_floor() and sign(direction) == sign(velocity.x) and abs(velocity.x) > MAX_SPEED:
		velocity.x = move_toward(velocity.x, MAX_SPEED * (direction if direction else 0.0), DECEL * delta)
	else:
		velocity.x = MAX_SPEED * (direction if direction else 0.0)


const BUCKET = preload("res://scenes/objects/bucket.tscn")
var BUCKET_FORCE = 1200.0
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

var BUCKET_DOUBLE_JUMP_X_FORCE = 600.0
var BUCKET_DOUBLE_JUMP_Y_FORCE = 1200.0
func double_jump() -> void:
	if state == State.OFF_BUCKET: return
	var new_bucket = BUCKET.instantiate()
	new_bucket.linear_velocity = Vector2(sign(velocity.x) * BUCKET_DOUBLE_JUMP_X_FORCE, BUCKET_DOUBLE_JUMP_Y_FORCE)
	new_bucket.position = position + Vector2(0.0, 10.0)
	get_parent().add_child(new_bucket)
	update_state(State.OFF_BUCKET)

func equip_bucket() -> void:
	update_state(State.ON_BUCKET)
	bucket_sprite_2d.rotation = 0.0

func update_state(new_state: State) -> void:
	state = new_state
	on_collision_shape_2d.set_deferred("disabled", not state == State.ON_BUCKET)
	off_collision_shape_2d.set_deferred("disabled", state == State.ON_BUCKET)
	bucket_sprite_2d.visible = state == State.ON_BUCKET

@onready var bucket_sprite_2d: AnimatedSprite2D = $BucketSprite2D

var WALK_FPS_OFF = 8.0
var WALK_FPS_SLOW = 6.0
var WALK_FPS_MED = 9.0
var WALK_FPS_FAST = 12.0
var BUCKET_ROTATE_AIR = 10.0
var BUCKET_ROTATE_ROLL = 0.03
var bucket_angle: float = 0.0
var bucket_rotation_dir: int

func handle_sprite(delta: float) -> void:
	sprite.flip_h = facing < 0.0
	sprite.speed_scale = 1.0
	if not is_on_floor():
		bucket_sprite_2d.play("air")
		if not bucket_rotation_dir:
			bucket_rotation_dir = signi(velocity.x)
			if not bucket_rotation_dir:
				bucket_rotation_dir = 1
		bucket_angle += bucket_rotation_dir * BUCKET_ROTATE_AIR * delta
		if velocity.y < 0.0:
			sprite.play("jump")
		else:
			sprite.play("fall")
	else:
		bucket_rotation_dir = 0
		bucket_sprite_2d.play("roll")
		if velocity.x:
			bucket_angle += velocity.x * BUCKET_ROTATE_ROLL * delta
			sprite.play("run")
			if state == State.OFF_BUCKET:
				sprite.speed_scale = WALK_FPS_OFF
			elif abs(velocity.x) > 550.0:
				sprite.speed_scale = WALK_FPS_FAST
			elif abs(velocity.x) > 350.0:
				sprite.speed_scale = WALK_FPS_MED
			else:
				sprite.speed_scale = WALK_FPS_SLOW
		else:
			sprite.play("idle")

	if state == State.ON_BUCKET:
		sprite.position = Vector2(0.0, -40.0)
	else:
		sprite.position = Vector2(0.0, 2.0)

	bucket_sprite_2d.rotation = bucket_angle
