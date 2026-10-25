extends Node2D

signal launched(cat: RigidBody2D)

const MAX_PULL := 120.0
const POWER := 12.5  # скорость вылета (px/sec)
const GRAB_RADIUS := 60.0
const DOTS := 12

@export var cat_scene: PackedScene

var cat: RigidBody2D = null
var dragging := false

@onready var pouch: Marker2D = $Pouch
@onready var band_back: Line2D = $BandBack
@onready var band_front: Line2D = $BandFront
@onready var aim: Node2D = $Aim


func _ready() -> void:
	for i in DOTS:
		var dot := Sprite2D.new()
		dot.texture = preload("res://art/game/dot.png")
		aim.add_child(dot)


func load_cat() -> void:
	cat = cat_scene.instantiate()
	get_parent().add_child(cat)  # кот должен летать внутри уровня, а не в рогатке
	cat.global_position = pouch.global_position


func _unhandled_input(event: InputEvent) -> void:
	if cat == null or not event is InputEventMouseButton or event.button_index != MOUSE_BUTTON_LEFT:
		return
	if event.pressed and get_global_mouse_position().distance_to(pouch.global_position) < GRAB_RADIUS:
		dragging = true
	elif not event.pressed and dragging:
		dragging = false
		shoot()


func _process(_delta: float) -> void:
	if dragging:
		var pull := (get_global_mouse_position() - pouch.global_position).limit_length(MAX_PULL)
		cat.global_position = pouch.global_position + pull
	var end := to_local(cat.global_position) if cat else pouch.position
	band_back.set_point_position(1, end)
	band_front.set_point_position(1, end)
	update_aim()


func shoot() -> void:
	cat.launch(launch_velocity())
	launched.emit(cat)
	cat = null


func launch_velocity() -> Vector2:
	return (pouch.global_position - cat.global_position) * POWER


# точки траектории: позиция = старт + v*t + g*(t^2)/2
func update_aim() -> void:
	aim.visible = dragging
	if not dragging:
		return
	var v := launch_velocity()
	var g := Vector2(0, ProjectSettings.get_setting("physics/2d/default_gravity"))
	for i in DOTS:
		var t := 0.08 * (i + 1)
		aim.get_child(i).global_position = cat.global_position + v * t + g * t * t / 2
