class_name Player
extends Entity

## speed of the player
const SPEED = 100.0
const ACCELERATE = 50.0
const JUMP_VELOCITY = -300.0
@onready var flipable: Node2D = $Flipable
@onready var fsm: FSM = $FSM
@onready var tail_line: Line2D = %TailLine2D
static var local_instance: Player

var last_velocity: Vector2
var facing_right := true:
	set(p_facing_right):
		if facing_right != p_facing_right:
			tail_line.position *= -1
			flipable.transform.x *= -1
			facing_right = p_facing_right


func _init() -> void:
	if not local_instance:
		local_instance = self


func _ready() -> void:
	Log.info("Player Instance Ready")

	Console.add_command("tp", _command_tp, "teleport player to given coordinate, or where the mouse cursor is pointing")

	await Lib.ensure_ready(Player.local_instance)


func _command_tp(x: float = INF, y: float = INF):
	var target: Vector2i
	target = World.Cursor.coord if is_inf(y) else World.Map.h2gui(Vector2(x, y))
	Player.local_instance.position = World.Map.to_pos(target)


func _physics_process(delta: float) -> void:
	super(delta)
	if not is_on_floor():
		velocity += get_gravity() * delta
		if not fsm.is_state("Fall") or fsm.is_state("JumpRev"):
			if last_velocity.y <= 0 and velocity.y > 0 and fsm.is_state("JumpUpward"):
				fsm.change_to("JumpRev")
			elif last_velocity.y > 0 and velocity.y > 0 and not $RayCastDown.is_colliding():
				fsm.change_to("JumpRev")

	elif is_on_floor():
		if World.input("pressed", &"jump") and not $RayCastAboveHead.is_colliding():
			fsm.change_to("JumpUpward")
			velocity.y = JUMP_VELOCITY
		elif last_velocity.y > 0:
			if velocity.x != 0:
				fsm.change_to("Run")
			else:
				fsm.change_to("Land")

	var direction: float
	if World.input_cut:
		direction = 0
	else:
		direction = Input.get_axis(&"left", &"right")

	var speed := SPEED * _get_speed_factor()

	if direction:
		if [&"Idle", &"Land", &"Mine"].has(fsm.state.name) and is_on_floor():
			fsm.change_to("StartRun")
		velocity.x = move_toward(velocity.x, direction * speed, ACCELERATE)
		facing_right = direction >= 0
	else:
		if last_velocity.x != 0 and is_on_floor():
			fsm.change_to("Idle")
		velocity.x = move_toward(velocity.x, 0, ACCELERATE)

	last_velocity = velocity
	move_and_slide()


func _process(delta: float) -> void:
	if World.input("pressed", &"mine_and_attack"):
		if not _is_mining:
			_is_mining = true
		if fsm.is_state("Idle"):
			fsm.change_to("Mine")
		mine_at(World.Cursor.coord, delta)
	else:
		if _is_mining:
			_is_mining = false
		if fsm.is_state("Mine"):
			fsm.change_to("Idle")
	if World.input("pressed", &"lay_and_interact"):
		lay_at(World.Cursor.coord)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("drop", true) and not World.input_cut:
		drop_item()


const REACH_RANGE := Vector2i(10, 10)

# Maybe player cannot mine a tile when there's a wall between??(Not a good idea actually)
const MINE_SPEED = 1.0
const MINE_RANGE := REACH_RANGE

var _is_mining := false
func mine_at(coords: Vector2i, delta: float):
	var offset := (coords - self.coord).abs()
	if offset.clamp(Vector2i.ZERO, MINE_RANGE) != offset:
		return
	var block := Room.current.get_block_safe(coords)
	if not block:
		return
	block.mined(MINE_SPEED, delta)


#Minecraft mining system as reference TODO: improve current mechanics
#if (isBestTool):
#	speedMultiplier = toolMultiplier
#if (not canHarvest):
#	speedMultiplier = 1
#else if (toolEfficiency):
#	speedMultiplier += efficiencyLevel ^ 2 + 1
#if (hasteEffect):
#	speedMultiplier *= 0.2 * hasteLevel + 1
#if (miningFatigue):
#	speedMultiplier *= 0.3 ^ min(miningFatigueLevel, 4)
#if (inWater and not hasAquaAffinity):
#	speedMultiplier /= 5
#if (not onGround):
#	speedMultiplier /= 5
#	damage = speedMultiplier / blockHardness
#if (canHarvest):
#	damage /= 30
#else:
#	damage /= 100
## Instant breaking
#if (damage > 1):
#	return 0
#	ticks = roundup(1 / damage)
#	seconds = ticks / 20
#	return seconds

const PlaceDetect := preload("res://scr/roles/entities/player/place_detect/place_detect.gd")
var _place_detect_lists: Dictionary[Vector2i, PlaceDetect] = {}

const LAY_RANGE := REACH_RANGE


func lay_at(coords: Vector2i):
	# coords check
	if not Room.current.has_coord(coords):
		return
	var offset := (coords - self.coord).abs()
	if offset.clamp(Vector2i.ZERO, MINE_RANGE) != offset:
		return

	# collision detect
	var place_detect: PlaceDetect
	if coords in _place_detect_lists:
		place_detect = _place_detect_lists[coords]
	else:
		place_detect = PlaceDetect.SCENE.instantiate()
		place_detect.global_position = World.Map.to_pos(coords)
		World.add_node(place_detect, "PlaceDetects")
		_place_detect_lists[coords] = place_detect
		await place_detect.ready

	for i in 2:  #safer check
		await get_tree().physics_frame
		if not place_detect.can_lay():
			return

	#inventory check
	if not (ItemSlotContainer.selected and ItemSlotContainer.selected.item):
		return

	#previous block check
	var held_meta := ItemSlotContainer.selected.item.meta
	if not "block" in held_meta:
		return
	var block := Room.current.get_block(coords)
	var new_block := Block.create(held_meta["block"])
	if not block:
		ItemSlotContainer.selected.amount -= 1
		Room.current.place_block(coords, new_block)
		Stats.block(new_block.config.name).place_counts += 1
	else:
		return


#
#
const DROP_IMPULSE = 200.0
const DROP_INITIAL_OFFSET = 5.0
const DROP_ANGLE_OFFSET = TAU / 20


func drop_item():
	var item := ItemSlotContainer.selected.item
	if not item or ItemSlotContainer.current_focused != UI.instance.backpack:
		return
	ItemSlotContainer.selected.amount -= 1

	var is_right := 1 if facing_right else -1
	var dire_vector := Vector2(is_right, 0)
	var drop_velocity := dire_vector * DROP_IMPULSE
	var local_mouse := get_local_mouse_position()
	var angle_offset := randf_range(-DROP_ANGLE_OFFSET, DROP_ANGLE_OFFSET)
	drop_velocity = drop_velocity.rotated(-local_mouse.angle_to(dire_vector) + angle_offset)  #mouse control
	drop_velocity += velocity  #inertia

	var drop_position = self.global_position
	drop_position.x += is_right * DROP_INITIAL_OFFSET
	var drop := Item.drop_at_global_pos(drop_position, item, drop_velocity)
	$DropCollect.add_to_blacklist(drop)


#
#
func get_save() -> Dictionary[String, Variant]:
	var save: Dictionary[String, Variant] = {
		"facing_right": facing_right,
	}
	SL.save_vector2(position, "position", save)
	SL.save_vector2(velocity, "velocity", save)
	return save


func load_save(save: Dictionary) -> void:
	position = SL.load_vector2("position", save)
	velocity = SL.load_vector2("velocity", save)
	SL.load_to_node(self, save)
