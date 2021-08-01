const Date = preload("res://Scenes/Scripts/Date.gd")
const Types = preload("res://Scenes/Scripts/Types.gd")

var dates = []

var rng
var character
var modifier

func _init(rand, chara, mod):
	rng = rand
	character = chara
	modifier = mod
	var start = rng.randi_range(0,3)
	for i in range(0,2):
		var d = Date.new()
		d.attraction = character.attractiveness
		d.element = (start+i)%4
		dates.push_back(d)

func update():
	for i in range(0,dates.size()):
		if(dates[i].attraction <= 0):
			dates.remove(i)
			
func get(i:int):
	assert(i>=0)
	assert(i<=2)
	return dates[i]


func printString():
	for date in dates:
		print("\tDate: " + str(date.attraction) + ", " + str(date.element))


func addNewDates():
	while(dates.size() < 3):
		print("Too few dates")
		var start = rng.randi_range(0, 3)
		for i in range(0, 4):
			var stop = true
			for date in dates:
				if(date.element == (i+start)%4):
					stop = false
					break
			if(stop):
				var d = Date.new()
				d.attraction = character.attractiveness
				d.element = (start+i)%4
				dates.push_back(d)

func processAnswer(e):
	for date in dates:
		if(Types.new().compatible(date.element, e)):
			date.attraction += modifier
		else:
			date.attraction -= modifier
	
