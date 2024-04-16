class_name Litter
extends Area2D

enum State { EMPTY, FILLING, FULL }

@export var NORMAL_TEXTURE: Texture2D
@export var FULL_TEXTURE: Texture2D
@onready var PARENT_SIZE := (get_parent() as Game).SIZE
@onready var SIZE := \
    (($CollisionShape2D as CollisionShape2D).shape as RectangleShape2D).size

var state: int:
    set(value):
        state = value
        match state:
            State.EMPTY, State.FILLING:
                ($Sprite2D as Sprite2D).texture = NORMAL_TEXTURE
            State.FULL: ($Sprite2D as Sprite2D).texture = FULL_TEXTURE

func _ready() -> void:
    position.x = randf_range(
        -PARENT_SIZE.x / 2.0 + SIZE.x / 2.0,
        PARENT_SIZE.x / 2.0 - SIZE.x / 2.0,
    )
    position.y = randf_range(
        -PARENT_SIZE.y / 2.0 + SIZE.y / 2.0,
        PARENT_SIZE.y / 2.0 - SIZE.y / 2.0,
    )
    self.state = State.EMPTY

func _on_body_entered(body: Node2D) -> void:
    if body is Cat: (body as Cat).on_litter_entered(self)
    elif body is Player: (body as Player).on_litter_entered(self)

func _on_body_exited(body: Node2D) -> void:
    if body is Cat: (body as Cat).on_litter_exited(self)
    elif body is Player: (body as Player).on_litter_exited(self)

func next_state() -> void: match state:
    State.EMPTY: self.state = State.FILLING
    State.FILLING: self.state = State.FULL
    State.FULL: self.state = State.EMPTY
