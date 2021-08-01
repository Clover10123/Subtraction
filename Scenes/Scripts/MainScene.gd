extends Node2D


onready var alert = $AlertWindow/AlertText


func _ready():
	$AlertWindow.hide()


func _on_PlayButton_pressed():
	$ConfirmAudioPlayer.play()
	if get_tree().change_scene("res://Scenes/IntroScene.tscn") == OK:
		return
	else:
		$AlertWindow.show()
		update_alert_text("Error grabbing intro scene.")


func _on_Timer_timeout():
	$AlertWindow.hide()
	update_alert_text("")
	pass # Replace with function body.

func update_alert_text(msg:String):
	alert.text = msg
	if msg != "":
		$Timer.start(4.0)

