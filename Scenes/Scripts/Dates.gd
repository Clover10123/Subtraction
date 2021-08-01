const Date = preload("res://Scenes/Scripts/Date.gd")
const Types = preload("res://Scenes/Scripts/Types.gd")
const Characters = preload("res://Scenes/Scripts/Characters.gd")

const MAX_NUM_DATES = 15

var dates = []

var dateCounter = 0

var rng
var character
var modifier
var characters

func _init(rand, chara, mod):
	rng = rand
	character = chara
	modifier = mod
	characters = Characters.new()
	var start = rng.randi_range(0,3)
	for i in range(0,3):
		var d = Date.new(characters.pop())
		d.attraction = character.attractiveness
		d.element = (start+i)%4
		addDate(d)

func moreDatesAvailable():
	return dateCounter < MAX_NUM_DATES

func contestantsInQueue():
	return 15-dateCounter

func size():
	return dates.size()

func smitten():
	var ret = []
	for d in dates:
		if(d.attraction >= 100):
			ret.push_back(d)
	return ret

func addDate(d):
	if(moreDatesAvailable() && dates.size() < 3):
		dates.push_back(d)
		dateCounter = dateCounter + 1
		return true
	return false

func update():
	for i in range(0,dates.size()):
		if(dates[i].attraction <= 0):
			dates.remove(i)
			
func get(i):
	assert(i>=0)
	assert(i<=2)
	return dates[i]


func printString():
	for date in dates:
		print("\tDate: " + str(date.attraction) + ", " + str(date.element))


func addNewDates():
	## Returns the indices of the dates that were added
	var ret = []
	for j in range(0,3):
		if(dates.size() < 3):
			print("Too few dates: " + str(dates.size()))
			var start = rng.randi_range(0, 3)
			for i in range(0, 4):
				var stop = true
				for date in dates:
					if(date.element == (i+start)%4):
						stop = false
						break
					if(stop):
						var d = Date.new(characters.pop())
						d.attraction = character.attractiveness
						d.element = (start+i)%4
						addDate(d)
						ret.push_back(dates.size()-1)
						break
	return ret
					
func processAnswer(e):
	for date in dates:
		if(Types.new().compatible(date.element, e)):
			date.attraction += modifier
		else:
			date.attraction -= modifier
	

			
