class_name Bowl
extends Area2D

enum State { FULL, EMPTYING, EMPTY }

@export var NORMAL_TEXTURE: Texture2D
@export var EMPTY_TEXTURE: Texture2D
@onready var PARENT_SIZE := (get_parent() as Game).SIZE
@onready var RADIUS := \
    (($CollisionShape2D as CollisionShape2D).shape as CircleShape2D).radius

var state: int:
    set(value):
        state = value
        match state:
            State.FULL, State.EMPTYING:
                ($Sprite2D as Sprite2D).texture = NORMAL_TEXTURE
            State.EMPTY: ($Sprite2D as Sprite2D).texture = EMPTY_TEXTURE

func _ready() -> void:
    position.x = randf_range(
        -PARENT_SIZE.x / 2.0 + RADIUS,
        PARENT_SIZE.x / 2.0 - RADIUS,
    )
    position.y = randf_range(
        -PARENT_SIZE.y / 2.0 + RADIUS,
        PARENT_SIZE.y / 2.0 - RADIUS,
    )
    self.state = State.FULL

func _on_body_entered(body: Node2D) -> void:
    if body is Cat: (body as Cat).on_bowl_entered(self)
    elif body is Player: (body as Player).on_bowl_entered(self)

func _on_body_exited(body: Node2D) -> void:
    if body is Cat: (body as Cat).on_bowl_exited(self)
    elif body is Player: (body as Player).on_bowl_exited(self)

func next_state() -> void: match state:
    State.FULL: self.state = State.EMPTYING
    State.EMPTYING: self.state = State.EMPTY
    State.EMPTY: self.state = State.FULL
