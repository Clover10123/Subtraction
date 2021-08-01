extends Node2D

onready var SPEED_PATH = "res://speed.json"

const Q_TIMEOUT = 10

var character
var date
var q1
var q2
var rng
var question = q1
var answers = ["", ""]
var secondRound

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
	$DollysPanel/DollysText.text = introDialogue[introDialogueIndex]

func updateQuestion():
	$DatePanel/DateQuestionText.text = question.text
	answers[0] = rng.randi_range(0,3)
	answers[1] = (answers[0]+rng.randi_range(1,3))%4
	$AnswerPanel/Option1/Option1Label.text = question.ans[answers[0]]
	$AnswerPanel/Option2/Option2Label.text = question.ans[answers[1]]

func initSpeed():
	updateQuestion()
	time()
	
func ready(chara, dat, qOne, qTwo, rand):
	character = chara
	date = dat
	q1 = qOne
	q2 = qTwo
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
	var i = rng.randi_range(0,1)
	if(i==0):
		_on_Option1_pressed()
	else:
		_on_Option2_pressed()

func answer(e):
	date.processAnswerSpeed(e)
	if(date.attraction >= 100):
		lose()

	if(secondRound == false):
		secondRound = true
		question = q2
	else:
		get_parent().endSpeed()

func lose():
	print("Lose")
	## TODO switch to lose scene
	
func _on_Option1_pressed():
	if(state == SpeedState.SPEED):
		answer(answers[0])	


func _on_Option2_pressed():
	if(state == SpeedState.SPEED):
		answer(answers[1])
