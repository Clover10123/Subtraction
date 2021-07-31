extends Node2D

const Types = preload("res://Scenes/Scripts/Types.gd")
const Date = preload("res://Scenes/Scripts/Date.gd")
const Question = preload("res://Scenes/Scripts/Question.gd")

const PANEL_SZ = 3
const ROUND_QUESTION_NUM = 6
const MAX_NUM_DATES = 15
const NUM_QUESTIONS = 60

var rng = RandomNumberGenerator.new()

onready var alert = $AlertWindow/AlertText


func _ready():
	$AlertWindow.hide()
	rng.randomize()

func _on_PlayButton_pressed():
	if get_tree().change_scene("res://GameScene.tscn") == OK:
		return
	else:
		$AlertWindow.show()
		update_alert_text("Error grabbing game scene.")


func _on_Timer_timeout():
	$AlertWindow.hide()
	update_alert_text("")
	pass # Replace with function body.

func update_alert_text(msg:String):
	alert.text = msg
	if msg != "":
		$Timer.start(4.0)

enum GameState {INTRO, PANEL, SPEED, OUTRO}

var state = INTRO
var dates = []
var questions = []
var character = Character.new()
var round = 0
var questionCounter = 0

func getQuestion():
	var ret = question[questionCounter%NUM_QUESTIONS]
	questionCounter++
	return ret

func initDating():
	## TODO load and sort questions for real
	for i in range(0, NUM_QUESTIONS):
		questions.push_back(Question.new())
	var start = rng.randi_range(0,3)
	for i in range(0,2):
		var d = Date.new()
		d.attraction = character.attractiveness
		d.element = (start+i)%4
		dates.push_back(d)
	
func initRound():
	while(dates.size() < 3):
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
		
	
func initIntro():
	print("Intro")
	state = PANEL
	
func gameLoop():
	match state:
		INTRO:
			initIntro()
		PANEL:
			if(round==0):
				initDating()
			initRound()
			
