extends Node2D



func _on_YesButton_pressed():
	pass # Replace with function body.


func _on_ProceedTextButton_pressed():
	$IntroDialoguePanel/ProceedTextButton.disabled = true
	pass # Replace with function body.


func _on_PlayButton_pressed():
	pass # Replace with function body.


func _on_AnimationPlayer_animation_finished(anim_name):
	$IntroDialoguePanel/ProceedTextButton.disabled = false
	pass # Replace with function body.
