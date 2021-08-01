extends Node2D

const Types = preload("res://Scenes/Scripts/Types.gd")
const Date = preload("res://Scenes/Scripts/Date.gd")
const Dates = preload("res://Scenes/Scripts/Dates.gd")
const Question = preload("res://Scenes/Scripts/Question.gd")
const Character = preload("res://Scenes/Scripts/Character.gd")
onready var QUESTIONS_PATH = "res://questions.json"

const modifier = 5
const ROUND_QUESTION_NUM = 6
const NUM_QUESTIONS = 60

var rng = RandomNumberGenerator.new()

enum GameState {INTRO, PANEL, SPEED, OUTRO}

var state = GameState.INTRO
var questions = []
var answers = ["", ""]
var character = Character.new()
var roundNum = 0
var questionCounter = 0
var roundQuestionNumber = 0
var dates


func _ready():
	rng.randomize()
	randomize()
	var file = File.new()
	var err = file.open(QUESTIONS_PATH, File.READ)
	print("File status: " + str(err))
	print("File path: " + file.get_path_absolute())
	print("File len: " + str(file.get_len()))
	var content = file.get_as_text()
	file.close()
	var p = JSON.parse(content)
	if p.error != OK:
		print("Error line: " + str(p.get_error_line()))
		print("Error: " + p.get_error_string())
		print("Error code: " + str(p.error))
	for item in p.result:
		var q = Question.new()
		q.text = item.question
		for i in range(0,4):
			q.ans[i] = item.answers[i]
		questions.push_back(q)
	initIntro()

func getCurrentQuestion():
	return questions[(questionCounter+NUM_QUESTIONS-1)%NUM_QUESTIONS]

func formatQuestion():
	var val = roundQuestionNumber%6
	if(val==0): return 6
	return val

func getQuestion():
	var ret = questions[questionCounter%NUM_QUESTIONS]
	roundQuestionNumber = (roundQuestionNumber+1)
	questionCounter = questionCounter+1
	return ret
	
func updateDates():
	$DatePanel/Date1Affection.set_value(dates.get(0).attraction)
	$DatePanel/Date2Affection.set_value(dates.get(1).attraction)
	$DatePanel/Date3Affection.set_value(dates.get(2).attraction)
	dates.update()

func initDating():
	print("Init Dating")
	questions.shuffle()
	dates = Dates.new(rng, character, modifier)
	updateDates()
	initRound()

func initQuestion():
	dates.printString()
	var q = getQuestion()
	$DatePanel/QuestionLabel.text = "R" + str(roundNum) +  "Q" + str(formatQuestion()) + ": " + q.text
	answers[0] = rng.randi_range(0,3)
	answers[1] = (answers[0]+rng.randi_range(1,3))%4
	$AnswerPanel/Option1/Option1Label.text = q.ans[answers[0]]
	$AnswerPanel/Option2/Option2Label.text = q.ans[answers[1]]
	
func initRound():
	print("Init round")
	print("Contestants in queue: " + str(dates.contestantsInQueue()))
	dates.addNewDates()
	if(dates.size() == 0 || roundNum > 4):
		win()
	initQuestion()
	
func initIntro():
	print("Intro")
	state = GameState.PANEL
	initDating()			

func answer(e):
	dates.processAnswer(e)
	updateDates()
	print("Question " + str(roundQuestionNumber))
	var smitten = dates.smitten()
	if(smitten.size()!=0):
		lose() ## Todo replace with speed date
	if(formatQuestion()!=6):
		initQuestion()
	else:
		roundNum = roundNum+1
		initRound()

func win():
	print("You won the game")
	if get_tree().change_scene("res://Scenes/MainScene.tscn") == OK:
		return
	else:
		$AlertWindow.show()
		update_alert_text("Error grabbing game scene.")
	
func lose():
	print("You lost the game")
	if get_tree().change_scene("res://Scenes/MainScene.tscn") == OK:
		return
	else:
		$AlertWindow.show()
		update_alert_text("Error grabbing game scene.")

func _on_Option1_pressed():
	answer(answers[0])


func _on_Option2_pressed():
	answer(answers[1])
 
