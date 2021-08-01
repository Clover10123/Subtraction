extends Node2D

var steps = [0,1,2,3,4,5,6]
onready var animator = $AnimationPlayer

func _ready():
	$IntroDialoguePanel/ProceedTextButton.disabled = true
	intro_handler()

func _on_YesButton_pressed():
	$IntroDialoguePanel/YesButton.hide()
	$IntroDialoguePanel/ProceedTextButton.show()
	intro_handler()
	pass # Replace with function body.


func _on_ProceedTextButton_pressed():
	$IntroDialoguePanel/ProceedTextButton.disabled = true
	intro_handler()
	pass # Replace with function body.


func _on_PlayButton_pressed():
	if get_tree().change_scene("res://Scenes/GameScene.tscn") == OK:
		return
	else:
		$IntroDialoguePanel/DialogueBox/DialogueText.text = "Oh sorry... there seems to be an issue with the game's stage. Can I actually call you back about that?"
		print("Error grabbing game scene. Error at IntroScene.gd. Is the file path spelled wrong?")
	pass # Replace with function body.


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "intro2": #asks the player if they want to join the game. Opens a button that says yes
		$IntroDialoguePanel/ProceedTextButton.hide()
		$IntroDialoguePanel/YesButton.show()
	elif anim_name == "introfinal":
		$IntroDialoguePanel/ProceedTextButton.hide()
		$IntroDialoguePanel/PlayButton.show()
	$IntroDialoguePanel/ProceedTextButton.disabled = false
	pass # Replace with function body.

func intro_handler():
	match steps[0]:
		null:
			pass
		0:
			animator.play("intro1")
			steps.pop_front()
		1:
			animator.play("intro2")
			steps.pop_front()
		2:
			animator.play("intro3")
			steps.pop_front()
		3:
			animator.play("intro4")
			steps.pop_front()
		4:
			animator.play("intro5")
			steps.pop_front()
		5:
			animator.play("intro6")
			steps.pop_front()
		6:
			animator.play("introfinal")
			steps.pop_front()
		_:
			animator.play("introfinal")

func _on_SkipIntroButton_pressed():
	if get_tree().change_scene("res://Scenes/GameScene.tscn") == OK:
		return
	else:
		$IntroDialoguePanel/DialogueBox/DialogueText.text = "Sorry... something seems to be wrong with the game stage. Can I call you back about that?"
		print("Error grabbing game scene. Error at IntroScene.gd. Is the file path spelled wrong?")
	pass # Replace with function body.
