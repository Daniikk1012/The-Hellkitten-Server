class_name Cat
extends CharacterBody2D

enum State {
    IDLE_BEFORE_POOPING,
    IDLE_BEFORE_EATING,
    WANT_POOPING,
    WANT_EATING,
    POOPING,
    EATING,
}

@export var SPEED: float
@export var NORMAL_TEXTURE: Texture2D
@export var ANGRY_TEXTURE: Texture2D
@onready var PARENT_SIZE := (get_parent() as Game).SIZE
@onready var SIZE := \
    (($CollisionShape2D as CollisionShape2D).shape as RectangleShape2D).size

var litters: Array[Litter] = []
var filling: Litter = null

var bowls: Array[Bowl] = []
var emptying: Bowl = null

var target := Vector2()

var state: int:
    set(value):
        state = value
        match state:
            State.IDLE_BEFORE_POOPING, State.IDLE_BEFORE_EATING:
                ($Timer as Timer).start(5.0)
            State.WANT_POOPING, State.WANT_EATING: ($Timer as Timer).start(INF)
            State.POOPING, State.EATING: ($Timer as Timer).start(1.0)
        next_target()
var angry := false

func next_target() -> void: match state:
    State.IDLE_BEFORE_POOPING, State.IDLE_BEFORE_EATING:
        target.x = randf_range(
            -PARENT_SIZE.x / 2.0 + SIZE.x / 2.0,
            PARENT_SIZE.x / 2.0 - SIZE.x / 2.0,
        )
        target.y = randf_range(
            -PARENT_SIZE.y / 2.0 + SIZE.y / 2.0,
            PARENT_SIZE.y / 2.0 - SIZE.y / 2.0,
        )
    State.WANT_POOPING:
        var closest: Litter = null
        for child in get_parent().get_children(): if child is Litter:
            var litter := child as Litter
            if litter.state == Litter.State.EMPTY and (
                closest == null
                or position.distance_squared_to(litter.position)
                < position.distance_squared_to(closest.position)
            ):
                closest = litter
        if closest == null:
            target = ($'../Player' as Node2D).position
            ($Sprite2D as Sprite2D).texture = ANGRY_TEXTURE
            if not angry:
                angry = true
                ($Angry as AudioStreamPlayer2D).play()
        else:
            target = closest.position
            ($Sprite2D as Sprite2D).texture = NORMAL_TEXTURE
            angry = false
    State.WANT_EATING:
        var closest: Bowl = null
        for child in get_parent().get_children(): if child is Bowl:
            var bowl := child as Bowl
            if bowl.state == Bowl.State.FULL and (
                closest == null
                or position.distance_squared_to(bowl.position)
                < position.distance_squared_to(closest.position)
            ):
                closest = bowl
        if closest == null:
            target = ($'../Player' as Node2D).position
            ($Sprite2D as Sprite2D).texture = ANGRY_TEXTURE
            if not angry:
                angry = true
                ($Angry as AudioStreamPlayer2D).play()
        else:
            target = closest.position
            ($Sprite2D as Sprite2D).texture = NORMAL_TEXTURE
            angry = false
    State.POOPING, State.EATING: target = position

func _ready() -> void:
    self.state = State.IDLE_BEFORE_POOPING
    ($Sprite2D as Sprite2D).texture = NORMAL_TEXTURE
    ($Cat as AudioStreamPlayer2D).play()

func next_state() -> void: match state:
    State.IDLE_BEFORE_POOPING: self.state = State.WANT_POOPING
    State.IDLE_BEFORE_EATING: self.state = State.WANT_EATING
    State.WANT_POOPING: self.state = State.POOPING
    State.WANT_EATING: self.state = State.EATING
    State.POOPING:
        self.state = State.IDLE_BEFORE_EATING
        filling.next_state()
        filling = null
        ($Poop as AudioStreamPlayer2D).play()
    State.EATING:
        self.state = State.IDLE_BEFORE_POOPING
        emptying.next_state()
        emptying = null
        ($Eat as AudioStreamPlayer2D).play()

func _physics_process(delta: float) -> void:
    var distance := position.distance_to(target)

    velocity = position.direction_to(target) \
        * move_toward(0.0, distance, SPEED * delta) / delta
    var _collided := move_and_slide()

    if velocity.x < 0.0: ($Sprite2D as Sprite2D).flip_h = true
    elif velocity.x > 0.0: ($Sprite2D as Sprite2D).flip_h = false

    if state != State.IDLE_BEFORE_POOPING \
        and state != State.IDLE_BEFORE_EATING \
        or distance < SPEED * delta \
    : next_target()

    match state:
        State.WANT_POOPING:
            for litter in litters: if litter.state == Litter.State.EMPTY:
                filling = litter
                break
            if filling != null:
                next_state()
                filling.next_state()
        State.WANT_EATING:
            for bowl in bowls: if bowl.state == Bowl.State.FULL:
                emptying = bowl
                break
            if emptying != null:
                next_state()
                emptying.next_state()
    if angry: for body in ($Area2D as Area2D).get_overlapping_bodies():
        if body is Player: (get_parent() as Game).game_over()

func _on_timer_timeout() -> void: next_state()

func on_litter_entered(litter: Litter) -> void: litters.push_back(litter)

func on_litter_exited(litter: Litter) -> void:
    litters.remove_at(litters.find(litter))

func on_bowl_entered(bowl: Bowl) -> void: bowls.push_back(bowl)

func on_bowl_exited(bowl: Bowl) -> void: bowls.remove_at(bowls.find(bowl))
