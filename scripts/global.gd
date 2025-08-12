extends Node

var suck_bucket := false
var magic_missile := false
var homing_bucket := false

var double_jump := false
var dash := false

#@export_category("Levels")
@export var levels: Array[PackedScene]

var current_level: int

func _ready() -> void:
	current_level = 0

func load_first_level() -> void:
	current_level = 0
	get_tree().change_scene_to_packed(levels[current_level])

func load_next_level() -> void:
	current_level += 1
	get_tree().change_scene_to_packed(levels[current_level])
