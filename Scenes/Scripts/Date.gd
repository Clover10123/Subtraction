const Types = preload("res://Scenes/Scripts/Types.gd")

var attraction : int
var element
var texture

func _init(txtr):
	print("New character " + str(txtr) + ":" + get_class(txtr))
	texture = txtr
