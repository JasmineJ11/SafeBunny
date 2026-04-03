extends Area2D
@onready var password_panel: Panel = %PasswordPanel
@onready var password_label: Label = %PasswordLabel
@onready var button_weak: Button = %ButtonWeak
@onready var button_strong: Button = %ButtonStrong
@onready var fail_sound: AudioStreamPlayer2D = $FailSound
@onready var success_sound: AudioStreamPlayer2D = $SuccessSound
@onready var game_manager: Node = %GameManager


var is_triggered = false 

func _ready():
	password_panel.hide()
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not is_triggered:
		is_triggered = true
		start_pwevent()
		game_manager.play_notification_sound()

		
func start_pwevent():
	password_panel.show()
	button_weak.show()
	button_strong.show()
	password_label.text = "👾 A monster is attacking your account!
🔐 Set a password to protect yourself!"



func _on_button_weak_pressed() -> void:
	button_weak.hide()
	button_strong.hide()
	if fail_sound: fail_sound.play()
	password_panel.modulate = Color(0.977, 0.609, 0.6, 1.0) 
	password_label.text = "❗ OH NOOO! This password is too week!
	⚠️ It can be guessed easily!"
	await get_tree().create_timer(2.5).timeout
	password_panel.modulate = Color.WHITE
	password_label.text = "❗ You lose 1 heart!"
	await get_tree().create_timer(2).timeout
	game_manager.score -= 1
	game_manager.update_score()
	finish_event()
	

func _on_button_strong_pressed() -> void:
	button_weak.hide()
	button_strong.hide()
	if success_sound: success_sound.play()
	password_panel.modulate = Color(0.5, 1, 0.5) 
	password_label.text = "🛡 Strong password created!"
	await get_tree().create_timer(2.5).timeout
	password_panel.modulate = Color.WHITE
	password_label.text = "✨ You protected your information!
	✨ You got 1 heart!"
	await get_tree().create_timer(2.5).timeout
	password_label.text = "🐱 Complex and unpredictable passwords are the safest!"
	await get_tree().create_timer(3).timeout
	game_manager.score += 1
	game_manager.update_score()
	finish_event()
	
func finish_event():
	password_panel.hide()
	password_panel.modulate = Color.WHITE 
	is_triggered = false
	get_tree().paused = false
