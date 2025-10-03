extends RigidBody2D
## [Drop]s are items that appear when mobs and some other entities die 
## or when most kinds of blocks are broken.

## The scene for a drop instance
const SCENE = preload("uid://cfp218urp3b0q")

## The item it holds
var item: Item

## target to move towards, typically a player
var target: Node2D:
	set = _update_target

## INFO this property is not currently used
## The player who drops the [Drop]. set null if not dropped by player
var previous_owner: Player
var _arrived := false

# node pointers
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	sprite_2d.texture = item.texture


func _update_target(new_target: Node2D) -> void:
	target = new_target
	_disable_physics()


func _disable_physics():
	set_deferred("freeze", true)
	collision_shape_2d.set_deferred("disabled", true)


# emulating the floating effect
var _anim_cnt: float

# emulating the floating effect
func _floating_anim() -> void:
	_anim_cnt += 0.1
	sprite_2d.global_position.y = global_position.y + sin(_anim_cnt)


func _physics_process(_delta: float) -> void:
	_floating_anim()
	#follow target
	if target:
		if _arrived:
			global_position = target.global_position
			return

		linear_velocity = (target.global_position - global_position) / 10
		if target is Entity:
			linear_velocity += target.velocity / 50
		#lower the numbers above are, easier it is to be collected
		var p_position = position + linear_velocity
		if (target.global_position - p_position).dot(linear_velocity) < 0.2:
			_arrived = true
			await Main.sleep(0.1)
			queue_free()
			return
		position = p_position
