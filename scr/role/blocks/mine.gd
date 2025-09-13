extends Sprite2D
## Mine
## Handle the mining process, including the visual effects and dropping
## NOTE: A [Mine] instance is not created until the block is attempted to be mined

const STATE = 10
const SIZE = Vector2(16, 16)
const SCENE_PATH = "res://scr/role/blocks/mine.tscn"
const SCENE = preload(SCENE_PATH)

var block: Block:
	set(p_block):
		assert(p_block)
		position = Main.Map.to_pos(p_block.coord)
		_block_ref = weakref(p_block)
		$AudioStreamPlayer2D.stream = block.config.destroy_or_mine
	get:
		return _block_ref.get_ref()

var _block_ref: WeakRef  # to avoid block not being freed after a new save is loaded

## Damage starts at 0 and accumulates as block being mined.[br]
## Break the block when it outnumbers the hardness[br]
var damage: float:
	set(p_damage):
		if p_damage > block.config.hardness and not _broken:
			_broken = true
			_on_end()
		damage = p_damage

## return if the a mining process is happening
func is_mining():
	return _mine_count > 0

# counter to track mining process
var _mine_count := 0
# avoid dropping more items than needed
var _broken := false


#TODO pass more information (who mine the block? What tools used?)
## mine the corresponding block
func mined(speed: float, delta: float):
	damage += speed * delta
	_mine_count += 1


func _process(delta: float) -> void:
	if not block:
		return
	if is_mining():
		_mine_count -= 1
		_update_sprite()
		if not $AudioStreamPlayer2D.playing:
			$AudioStreamPlayer2D.play()
	else:
		$AudioStreamPlayer2D.stop()
		if damage > 0:
			damage -= block.config.recovery * delta
			_update_sprite()
		


func _on_end():
	$AudioStreamPlayer2D.stop()
	Room.current.remove_block(block.coord)
	Stats.block(block.config.name).mined_counts += 1
	if block.config.drop:
		Item.drop_at(block.coord, block.config.drop.pick_random())
	self_modulate.a = 0
	await _emit_particle().finished
	queue_free()


func _update_sprite() -> void:
	if damage <= 0:
		hide()
		return
	show()
	texture.region.position.x = floori((damage / block.config.hardness) * 3) * SIZE.x


func _emit_particle() -> GPUParticles2D:
	var emitter: GPUParticles2D = $GPUParticles2D
	emitter.modulate = block.config.color
	emitter.emitting = true
	return emitter
