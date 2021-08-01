const Character = preload("res://Scenes/Scripts/Character.gd")

const CHARACTER_PATH = "res://textures/characters/dates/"

var characters = []
## characters is an array of texture files

func _init():
	print("Loading NPCs")
	var dir = Directory.new()
	dir.open(CHARACTER_PATH)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			print("\tLoading " + file)
			if file.ends_with(".import"):
				characters.append(load(CHARACTER_PATH+file.replace(".import", "")))

	dir.list_dir_end()

	
