extends Node2D

const Types = preload("res://Scenes/Scripts/Types.gd")
const Date = preload("res://Scenes/Scripts/Date.gd")
const Question = preload("res://Scenes/Scripts/Question.gd")
const Character = preload("res://Scenes/Scripts/Character.gd")
onready var QUESTIONS_PATH = "res://questions.json"

const PANEL_SZ = 3
const modifier = 5
const ROUND_QUESTION_NUM = 6
const MAX_NUM_DATES = 15
const NUM_QUESTIONS = 60

var rng = RandomNumberGenerator.new()

enum GameState {INTRO, PANEL, SPEED, OUTRO}

var state = GameState.INTRO
var dates = []
var questions = []
var answers = ["", ""]
var character = Character.new()
var roundNum = 0
var questionCounter = 0
var roundQuestionNumber = 0



func _ready():
	rng.randomize()
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
	gameLoop()

func getCurrentQuestion():
	return questions[(questionCounter+NUM_QUESTIONS-1)%NUM_QUESTIONS]

func getQuestion():
	var ret = questions[questionCounter%NUM_QUESTIONS]
	questionCounter = questionCounter+1
	return ret
	
func updateDates():
	$DatePanel/Date1Affection.set_value(dates[0].attraction)
	$DatePanel/Date2Affection.set_value(dates[1].attraction)
	$DatePanel/Date3Affection.set_value(dates[2].attraction)



func initDating():
	print("Init Dating")
	questions.shuffle()
	var start = rng.randi_range(0,3)
	for i in range(0,2):
		var d = Date.new()
		d.attraction = character.attractiveness
		d.element = (start+i)%4
		dates.push_back(d)
	updateDates()
	initRound()

func initQuestion():
	var q = getQuestion()
	print("Question is size: " + str(q.ans.size()))
	$DatePanel/QuestionLabel.text = q.text
	answers[0] = rng.randi_range(0,3)
	answers[1] = (answers[0]+rng.randi_range(1,3))%4
	$AnswerPanel/Option1/Option1Label.text = q.ans[answers[0]]
	$AnswerPanel/Option2/Option2Label.text = q.ans[answers[1]]
	
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
	initQuestion()
	
func initIntro():
	print("Intro")
	state = GameState.PANEL
	initDating()
	
func gameLoop():
	match state:
		GameState.INTRO:
			initIntro()
		GameState.PANEL:
			if(roundNum==0):
				initDating()
			if(roundQuestionNumber == 0):
				initRound()
			elif(roundQuestionNumber < ROUND_QUESTION_NUM):
				initQuestion()
			

func endRound():
	print("End round")
	roundQuestionNumber = 0
	roundNum = roundNum+1
	
func answer(e):
	for date in dates:
		if(Types.new().compatible(date.element, e)):
			date.attraction += modifier
		else:
			date.attraction -= modifier
	updateDates()
	if(roundQuestionNumber < ROUND_QUESTION_NUM-1):
		initQuestion()
	else:
		endRound()


func _on_Option1_pressed():
	answer(answers[0])


func _on_Option2_pressed():
	answer(answers[1])
