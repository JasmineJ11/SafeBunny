extends Area2D

@onready var attack_panel: Panel = %AttackPanel
@onready var attack_label: Label = %AttackLabel
@onready var button: Button = $"../CanvasLayer/AttackPanel/Button"

var is_triggered = false
var password: String
var is_active = false


func _ready():
	attack_panel.hide()


func _input(event):
	if is_active:
		if event is InputEventKey and event.is_pressed() and event.is_echo() == false:
			var code = DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode)
			password += (OS.get_keycode_string(code))
			print(password)
			attack_label.text = password
		
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not is_triggered:
		is_triggered = true
		attack_panel.show()
		attack_label.text = "set a password!"
		
		

func _on_button_pressed() -> void:
	button.hide()
	is_active = true;
	
	
	
