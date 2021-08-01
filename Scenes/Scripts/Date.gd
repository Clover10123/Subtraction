const Types = preload("res://Scenes/Scripts/Types.gd")

const MODIFIER = 10

var attraction : int
var element
var texture

func _init(txtr):
	print("New character " + str(txtr) + ":" )
	texture = txtr

func processAnswerSpeed(e):
	## Only used for speed dating
	if(Types.new().compatible(element, e)):
		attraction += MODIFIER
	else:
		attraction -= MODIFIER

