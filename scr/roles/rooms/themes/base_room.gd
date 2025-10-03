extends RoomTheme
# base room is not a "base class" of room,
# it's just a literal "base room"

func _spawn(_room: Room):
	Log.info("Spawning base room...")
	#SL.load_room("base")
