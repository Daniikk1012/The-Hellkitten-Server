class_name Game
extends Node2D

@export var SIZE: Vector2

@export var CAT_SCENE: PackedScene
@export var LITTER_SCENE: PackedScene
@export var BOWL_SCENE: PackedScene

var cats := 0

func init_boundary(node: Node, dimension: float) -> void:
    ((node.get_child(0) as CollisionShape2D).shape as WorldBoundaryShape2D) \
        .distance = -dimension / 2.0

func spawn() -> void:
    add_child(CAT_SCENE.instantiate())
    add_child(LITTER_SCENE.instantiate())
    add_child(BOWL_SCENE.instantiate())
    cats += 1
    ($CanvasLayer/MarginContainer/Label as Label).text = 'Hellkittens: %d' % cats

func _ready() -> void:
    init_boundary($LeftBoundary, SIZE.x)
    init_boundary($TopBoundary, SIZE.y)
    init_boundary($RightBoundary, SIZE.x)
    init_boundary($BottomBoundary, SIZE.y)
    spawn()

func restart() -> void: if get_tree().reload_current_scene() != OK:
    printerr('Could not reload the scene')
    get_tree().quit(1)

func _process(_delta: float) -> void:
    if Input.is_action_just_pressed('restart'): restart()

func _on_timer_timeout() -> void: spawn()

func game_over() -> void:
    ($Player as Player).game_over()
    ($Timer as Timer).stop()

func _on_button_pressed() -> void: restart()
