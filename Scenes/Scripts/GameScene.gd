extends Node2D

const Types = preload("res://Scenes/Scripts/Types.gd")
const Date = preload("res://Scenes/Scripts/Date.gd")
const Dates = preload("res://Scenes/Scripts/Dates.gd")
const Question = preload("res://Scenes/Scripts/Question.gd")
const Character = preload("res://Scenes/Scripts/Character.gd")
onready var QUESTIONS_PATH = "res://questions.json"
onready var HOST_PATH = "res://gameIntroDialogue.json"

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
var introDialogue = []
var introDialogueIndex = 0
var speedDates = []

func _ready():
	rng.randomize()
	randomize()
	var file = File.new()
	var err = file.open(QUESTIONS_PATH, File.READ)
	assert(err == OK)
	var content = file.get_as_text()
	file.close()
	var p = JSON.parse(content)
	assert(p.error == OK)
	for item in p.result:
		var q = Question.new()
		q.text = item.question
		for i in range(0,4):
			q.ans[i] = item.answers[i]
		questions.push_back(q)

	var hostFile = File.new()
	var err2 = hostFile.open(HOST_PATH, File.READ)
	assert(err2 == OK)
	var hostContent = hostFile.get_as_text()
	var p2 = JSON.parse(hostContent)
	assert(p2.error == OK)
	for item in p2.result:
		introDialogue.push_back(item)

	initIntro()

func _input(event):
	if event.is_action_pressed("click"):
		click_handler()

func click_handler():
	$SelectPlayer.play()
	if state == GameState.INTRO:
		if introDialogueIndex < introDialogue.size()-1:
			introDialogueIndex = introDialogueIndex+1
			updateIntroDialogue()
		else:
			initDating()

func updateIntroDialogue():
	# $HostAudio.play()
	$GameShowHost/HostTextPanel/HostText.text = introDialogue[introDialogueIndex]
	
func getCurrentQuestion():
	return questions[(questionCounter+NUM_QUESTIONS-1)%NUM_QUESTIONS]

func formatQuestion():
	var val = roundQuestionNumber%6
	if(val==0): return 6
	return val

func getQuestion(rd=true):
	var ret = questions[questionCounter%NUM_QUESTIONS]
	if(rd): roundQuestionNumber = (roundQuestionNumber+1)
	questionCounter = questionCounter+1
	return ret
	
func updateDates():
	var startSize = dates.size()
	if(dates.size()>=1):
		$DatePanel/Date1/Date1Affection.set_value(dates.get(0).attraction)
	if(dates.size()>=2):
		$DatePanel/Date2/Date2Affection.set_value(dates.get(1).attraction)
	if(dates.size()>=3):
		$DatePanel/Date3/Date3Affection.set_value(dates.get(2).attraction)
	dates.update()
	if(dates.size() < startSize):
		$ElimSound.play()

func initDating():
	state = GameState.PANEL
	print("Init Dating")
	$AnswerPanel/Option1.disabled = false
	$AnswerPanel/Option2.disabled = false

	questions.shuffle()
	dates = Dates.new(rng, character, modifier)
	for i in range(0,3):
		updateDateSprite(i)
	updateDates()
	initRound()

func initQuestion():
	for i in range(0,3):
		updateDateSprite(i)
	dates.printString()
	var q = getQuestion()
	$GameShowHost/HostTextPanel/HostText.text = "Round " + str(roundNum) + ", question " + str(formatQuestion()) + ". " + str(dates.contestantsInQueue()) + " contestants in queue, " + str(dates.size()) + " remaining in current round."
	$DatePanel/Panel/QuestionLabel.text = q.text
	answers[0] = rng.randi_range(0,3)
	answers[1] = (answers[0]+rng.randi_range(1,3))%4
	$AnswerPanel/Option1/Option1Label.text = q.ans[answers[0]]
	$AnswerPanel/Option2/Option2Label.text = q.ans[answers[1]]

func updateDateSprite(i):
	if(dates.size() < i+1):
		return
	var n
	match i:
			0: 
				n = $DatePanel/Date1
			1:
				n = $DatePanel/Date2
			2:
				n = $DatePanel/Date3
	var t = dates.get(i).texture
	if(t != null):
		n.set_texture(t)
	else:
		print("Warning: texture null for date " + str(i+1))
				
func initRound():
	print("Init round")
	print("Contestants in queue: " + str(dates.contestantsInQueue()))
	var modified = dates.addNewDates()
	for i in modified:
		updateDateSprite(i)	
	if(dates.size() == 0 || roundNum > 4):
		win()
	initQuestion()
	
func initIntro():
	print("Intro")
	state = GameState.INTRO

	# Disable buttons

	$AnswerPanel/Option1.disabled = true
	$AnswerPanel/Option2.disabled = true

	updateIntroDialogue()

func endAnswer():
	if(formatQuestion()!=6):
		initQuestion()
	else:
		roundNum = roundNum+1
		initRound()

func answer(e):
	dates.processAnswer(e)
	updateDates()
	print("Question " + str(roundQuestionNumber))
	var smitten = dates.smitten()
	if(smitten.size()!=0):
		for d in smitten:
			speedDates.push_back(d)
		initSpeedDate()
		return
	endAnswer()

func speedRound(date):
	var q1 = getQuestion(false)
	var q2 = getQuestion(false)
	$SpeedDatingScene.ready(character, date, q1, q2, rng)
	$SpeedDateMusic.play()
	$SpeedDatingScene.visible = true
	$SpeedDatingScene.start()

func speedDate():
	if(speedDates.size() != 0):
		var date = speedDates.pop_front()
		speedRound(date)
	else:
		endSpeedDate()


func initSpeedDate():
	state = GameState.SPEED
	$GameShowHost.visible = false
	$DatePanel.visible = false
	$PlayerSprite.visible = false
	$youlabel.visible = false
	$AnswerPanel.visible = false
	$GameShowMusic.stop()
	speedDate()

func endSpeedDate():
	$SpeedDatingScene.visible = false
	$SpeedDateMusic.stop()
	$GameShowHost.visible = true
	$DatePanel.visible = true
	$PlayerSprite.visible = true
	$youlabel.visible = true
	$AnswerPanel.visible = true
	$GameShowMusic.start()

	updateDates()
	state = GameState.PANEL
	endAnswer()
	
	
func win():
	print("You won the game")
	if get_tree().change_scene("res://Scenes/MainScene.tscn") == OK:
		return
	else:
		$AlertWindow.show()
		#update_alert_text("Error grabbing game scene.")
	
func lose():
	print("You lost the game")
	if get_tree().change_scene("res://Scenes/MainScene.tscn") == OK:
		return
	else:
		print("Error grabbing game scene")

func _on_Option1_pressed():
	if(state == GameState.PANEL):
		answer(answers[0])	


func _on_Option2_pressed():
	if(state == GameState.PANEL):
		answer(answers[1])
 


func _on_Option1_mouse_entered():
	if(state == GameState.PANEL):
		$HoverPlayer.play()


func _on_Option2_mouse_entered():
	if(state == GameState.PANEL):
		$HoverPlayer.play()
