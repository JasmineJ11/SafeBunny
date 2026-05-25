extends Area2D
@onready var game_manager: Node = %GameManager
@onready var goal_panel: Panel = %GoalPanel
@onready var goal_label: Label = %GoalLabel
@onready var goal_button: Button = %GoalButton
@onready var goal_sound: AudioStreamPlayer = $GoalSound

func _ready():
	goal_panel.hide()

func _on_body_entered(body):
	if body.name == "Player":
		%GameManager.show_game_over()
		goal_sound.play()