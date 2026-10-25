extends RigidBody2D

signal stopped  # кот остановился или улетел, можно подавать следующего

const STOP_SPEED := 20.0
const MAX_FLY_TIME := 8.0

var last_velocity := Vector2.ZERO
var flying := false
var fly_time := 0.0


func _ready() -> void:
	freeze = true  # до выстрела кот лежит в рогатке


func launch(velocity: Vector2) -> void:
	freeze = false
	flying = true
	apply_central_impulse(velocity * mass)


func _physics_process(delta: float) -> void:
	last_velocity = linear_velocity
	if not flying:
		return
	fly_time += delta
	var resting := fly_time > 1.0 and linear_velocity.length() < STOP_SPEED
	var out := position.y > 1000 or position.x < -200 or position.x > 2800
	if resting or out or fly_time > MAX_FLY_TIME:
		flying = false
		stopped.emit()
		queue_free()
