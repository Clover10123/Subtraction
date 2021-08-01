extends Node2D

onready var SPEED_PATH = "res://speed.json"

const Q_TIMEOUT = 10

var character
var date
var q1
var q2
var rng
var question
var answers = ["", ""]
var secondRound

var firstTimer = true

var introDialogue = []
var introDialogueIndex = 0

enum SpeedState  {INTRO, SPEED}

var state

func _ready():
	var speedFile = File.new()
	var err2 = speedFile.open(SPEED_PATH, File.READ)
	assert(err2 == OK)
	var speedContent = speedFile.get_as_text()
	var p2 = JSON.parse(speedContent)
	assert(p2.error == OK)
	for item in p2.result:
		introDialogue.push_back(item)
	secondRound = false


func initSpeed():
	state = SpeedState.SPEED
	print("Init speed")
	updateQuestion()
	time()
	

func _input(event):
	if event.is_action_pressed("click"):
		click_handler()


func click_handler():
	$SelectPlayer.play()
	if state == SpeedState.INTRO:
		if introDialogueIndex < introDialogue.size()-1:
			introDialogueIndex = introDialogueIndex+1
			updateIntroDialogue()
		else:
			initSpeed()

func updateIntroDialogue():
	# $HostAudio.play()
	$DollysPanel/DollyText.text = introDialogue[introDialogueIndex]

func updateQuestion():
	$DatePanel/DateQuestionText.text = question.text
	answers[0] = rng.randi_range(0,3)
	answers[1] = (answers[0]+rng.randi_range(1,3))%4
	$DatePanel/Option1Button/Option1Text.text = question.ans[answers[0]]
	$DatePanel/Option2Button/Option2Text.text = question.ans[answers[1]]
	
func ready(chara, dat, qOne, qTwo, rand):
	character = chara
	date = dat
	q1 = qOne
	q2 = qTwo
	question = q1
	introDialogueIndex = 0
	rng = rand

	$Date.set_texture(date.texture)

	state = SpeedState.INTRO


func start():
	updateIntroDialogue()

func time():
	var timer = Timer.new()
	timer.connect("timeout",self,"randomAnswer") 
	#timeout is what says in docs, in signals
	#self is who respond to the callback
	#_on_timer_timeout is the callback, can have any name
	add_child(timer) #to process
	timer.start(Q_TIMEOUT) #to start

func randomAnswer():
	print("Timer ran out!")

	if(firstTimer == true and secondRound == false):
		firstTimer = false
		return
	
	var i = rng.randi_range(0,1)
	if(i==0):
		_on_Option1Button_pressed()
	else:
		_on_Option2Button_pressed()
		
	firstTimer = false

func answer(e):
	date.processAnswerSpeed(e)
	if(date.attraction >= 100):
		lose()

	if(secondRound == false):
		secondRound = true
		question = q2
	else:
		get_parent().endSpeedDate()

func lose():
	print("You lost the game")
	if get_tree().change_scene("res://Scenes/MainScene.tscn") == OK:
		return
	else:
		print("Error grabbing game scene")
	
func _on_Option1Button_pressed():
	if(state == SpeedState.SPEED):
		answer(answers[0])	


func _on_Option2Button_pressed():
	if(state == SpeedState.SPEED):
		answer(answers[1])
