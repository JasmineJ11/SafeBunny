extends Area2D

@onready var attack_panel: Panel = %AttackPanel
@onready var attack_label: Label = %AttackLabel
@onready var button: Button = %AttackButton
@onready var line_edit: LineEdit = %AttackLineEdit
@onready var goodresults: AudioStreamPlayer = $goodresults
@onready var wrong: AudioStreamPlayer = $wrong
@onready var game_manager: Node = %GameManager




var is_triggered = false
#var password: String
var monster_hp = 4
#var is_active = false
var player: Node2D = null


func _ready():
	line_edit.hide()
	attack_panel.hide()
	
#

#func _input(event):
	#if is_active:
		#if event is InputEventKey and event.is_pressed() and event.is_echo() == false:
			#var code = DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode)
			#if (code & KEY_SPECIAL) == 0:
				#password += (OS.get_keycode_string(code))
				##print(password)
		
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not is_triggered:
		player = body
		is_triggered = true
		attack_panel.show()
		attack_label.text = "⚠️ The monster is attacking you!
		Set your password to defend yourself!"
		body.is_paused = true
		

func _on_button_pressed() -> void:
	button.hide()
	attack_label.text = "Type your password and press Enter!
	A strong password should include:
	⚠️Numbers\n⚠️Upper case\n⚠️Lower case\n⚠️Special characters\n"
	line_edit.show()
	#is_active = true;

func _on_line_edit_text_submitted(password: String) -> void:
	var score = 0
	var result_text = ""
	if password.length() < 6:
		attack_label.text = "Too short! (Min 6 chars)\nTry create a strong one!
							❌ You lost 1 safety point."
		game_manager.sub_Safetypoint()
		wrong.play()
		reset_panel()
		return

	var has_number = RegEx.create_from_string("[0-9]").search(password)
	var has_upper = RegEx.create_from_string("[A-Z]").search(password)
	var has_lower = RegEx.create_from_string("[a-z]").search(password)
	var has_special = RegEx.create_from_string("[^A-Za-z0-9]").search(password)
	if has_number: score += 1
	if has_upper: score += 1
	if has_lower: score += 1
	if has_special: score += 1

	var current_damage = score
	var remaining_hp = monster_hp - current_damage
	result_text += "Numbers " + ("✅" if has_number else "❌") + "  "
	result_text += "Upper " + ("✅" if has_upper else "❌") + "\n"
	result_text += "Lower " + ("✅" if has_lower else "❌") + "  "
	result_text += "Special " + ("✅" if has_special else "❌") + "\n"
	attack_label.text = result_text + "👾 Damage: " + str(current_damage) + "\n"

	if current_damage >= monster_hp:
		attack_label.text += "🎉 CRITICAL HIT! Monster Defeated!
		😎 You got 1 safety point!"
		goodresults.play()
		game_manager.add_Safetypoint()
		await get_tree().create_timer(4.5).timeout
		attack_panel.hide()
		player.is_paused = false
		reset_panel()
	else:
		attack_label.text += "👾 HP Remaining: " + str(max(0, remaining_hp)) + "\n⚠️ Try create a strong one!
		❌ You lost 1 safety point."
		game_manager.sub_Safetypoint()
		wrong.play()
		await get_tree().create_timer(3).timeout
		reset_panel()

func reset_panel():
	monster_hp = 4
	line_edit.text = "" 
	line_edit.show()    
	line_edit.grab_focus() 
	is_triggered = false
	

#//////////////////////////////////////////////////////////////
