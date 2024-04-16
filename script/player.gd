class_name Player
extends CharacterBody2D

@export var SPEED: float

var litters: Array[Litter] = []
var bowls: Array[Bowl] = []

var alive := true

func _process(_delta: float) -> void:
    if alive and Input.is_action_just_pressed('fix'):
        var processed := false
        for litter in litters: if litter.state == Litter.State.FULL:
            litter.next_state()
            processed = true
            break
        if not processed: for bowl in bowls: if bowl.state == Bowl.State.EMPTY:
            bowl.next_state()
            processed = true
            break
        if processed:
            ($Fix as AudioStreamPlayer).play()

func _physics_process(_delta: float) -> void: if alive:
    var direction := Vector2(
        Input.get_axis('move_left', 'move_right'),
        Input.get_axis('move_up', 'move_down'),
    ).limit_length()
    velocity = direction * SPEED
    var _collided := move_and_slide()

    if velocity.x < 0.0: ($Sprite2D as Sprite2D).flip_h = true
    elif velocity.x > 0.0: ($Sprite2D as Sprite2D).flip_h = false

func on_litter_entered(litter: Litter) -> void: litters.push_back(litter)

func on_litter_exited(litter: Litter) -> void:
    litters.remove_at(litters.find(litter))

func on_bowl_entered(bowl: Bowl) -> void: bowls.push_back(bowl)

func on_bowl_exited(bowl: Bowl) -> void: bowls.remove_at(bowls.find(bowl))

func game_over() -> void: if alive:
    alive = false
    ($Die as AudioStreamPlayer).play()
