extends Node2D
onready var animator = $AnimationPlayer
var quitprompt = false
var settingsopen = false
var music = true
var sound = true

func _ready():
	animator.play("default")
	
func _input(event):
	if event.is_action_pressed("settings"):
		settings_handler()

func _on_QuitButton_pressed():
	quit_handler()
	pass # Replace with function body.


func _on_ConfirmQuit_pressed():
	$ConfirmPlayer.play()
	get_tree().quit()
	pass # Replace with function body.


func _on_CancelQuit_pressed():
	$SelectPlayer.play()
	quit_handler()
	pass # Replace with function body.

func quit_handler():
	if quitprompt:
		animator.play("quitprompthide")
		quitprompt = false
	else:
		animator.play("quitpromptshow")
		quitprompt = true

func settings_handler():
	if settingsopen:
		animator.play("settingspanelhide")
		settingsopen = false
	else:
		animator.play("settingspanelshow")
		settingsopen = true


func _on_ConfirmQuit_mouse_entered():
	$HoverPlayer.play()


func _on_CancelQuit_mouse_entered():
	$HoverPlayer.play()

func _on_MusicButton_toggled(button_pressed):
	$SelectPlayer.play()
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), button_pressed)


func _on_SoundButton_toggled(button_pressed):
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), button_pressed)
	$SelectPlayer.play()
