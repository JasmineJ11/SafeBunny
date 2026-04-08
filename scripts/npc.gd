extends Area2D


@onready var chest_panel: Panel = %ChestPanel

@onready var label = chest_panel.get_node("%ChestLabel") 
@onready var blur_bg = chest_panel.get_node_or_null("%BlurBackground")
@onready var game_manager: Node = %GameManager

@onready var success_sound: AudioStreamPlayer2D = $SuccessSound
@onready var fail_sound: AudioStreamPlayer2D = $FailSound

@onready var yes_button: Button = %YesButton
@onready var no_button: Button = %NoButton


var event_data = [
	{
		"question": "Hi! 😊\nWhat’s your name and home address?\nI want to send you a gift! 🎁",
		"yes_text": "❗ That’s dangerous!\n⚠️ Your home address is private.",
		"no_text": "Good job! 👍\nNever share your address with strangers!",
		"yes_score": -1, # 选Yes扣1分
		"no_score": 1    # 选No加1分
	},
	{
		"question": "Quick! 🚨\nYour account is being hacked!\nSend me your password to save it!",
		"yes_text": "❗ Stop! Never share your password,\neven with 'support'!",
		"no_text": "Correct! ✅\nReal admins will never ask for your password.",
		"yes_score": -1,
		"no_score": 1
	},
	{
		"question": "Free WiFi! 📶 No password needed!\nConnect now?",
		"yes_text": "⚠️ Risky!\nPublic WiFi can be unsafe.",
		"no_text": "Good decision! 👍\nAvoid unknown networks.",
		"yes_score": -1,
		"no_score": 1
	},
	{
		"question": "This app asks for access to your camera 📷 and contacts list.\nAllow access?",
		"yes_text": "⚠️ Be careful!\nOnly allow permissions when necessary.",
		"no_text": "Good! 👍\nProtect your personal data.",
		"yes_score": -1,
		"no_score": 1
	}
]

var is_triggered = false 

func _ready():
	# 关键：游戏开始时，强制隐藏面板，防止它一开始就挡住屏幕 hide from begining
	chest_panel.hide()

# --- 1. player touch the chest ---
func _on_body_entered(body):
	if body.name == "Player" and not is_triggered:
		# 检查是否还有对话可以进行
		if game_manager.current_event_index < event_data.size():
			is_triggered = true
			start_npc_event(game_manager.current_event_index)
		else:
			chest_panel.show()
			game_manager.play_notification_sound()
			label.text = "Have a nice day ^^"
			await get_tree().create_timer(2.5).timeout
			chest_panel.hide()
			

# --- 2. start the window ---
func start_npc_event(index):
	var data = event_data[index]
	chest_panel.show()
	yes_button.show()
	no_button.show()
	
		# 如果已经连了，先断开（防止双重连接）
	if yes_button.pressed.is_connected(_on_yes_button_pressed):
		yes_button.pressed.disconnect(_on_yes_button_pressed)
	if no_button.pressed.is_connected(_on_no_button_pressed):
		no_button.pressed.disconnect(_on_no_button_pressed)
		
	# 现在只连这一个脚本的函数
	yes_button.pressed.connect(_on_yes_button_pressed)
	no_button.pressed.connect(_on_no_button_pressed)
	
	game_manager.play_notification_sound()
	
	label.text = data["question"]
	
	


# --- 3. click YES ---
func _on_yes_button_pressed():
	# scam
	var data = event_data[game_manager.current_event_index]
	yes_button.hide()
	no_button.hide()

	if fail_sound: fail_sound.play()
	chest_panel.modulate = Color(0.977, 0.609, 0.6, 1.0) # change color
	label.text = data["yes_text"]
	await get_tree().create_timer(3).timeout
	chest_panel.modulate = Color.WHITE # change color back
	
	label.text = "🛡️ You lose 1 safety point!"
	await get_tree().create_timer(2.0).timeout
	
	# lose 1 point
	#game_manager.sub_Safetypoint()
	if data["yes_score"] > 0: game_manager.add_Safetypoint()
	elif data["yes_score"] < 0: game_manager.sub_Safetypoint()
	finish_event()

# --- 4. Click NO ---
func _on_no_button_pressed():
	var data = event_data[game_manager.current_event_index]
	yes_button.hide()
	no_button.hide()
	if success_sound: success_sound.play()
	
	# feedback
	chest_panel.modulate = Color(0.5, 1, 0.5) # change color to green
	label.text = data["no_text"]
	await get_tree().create_timer(3.0).timeout
	chest_panel.modulate = Color.WHITE 
	
	label.text = "🛡️ You got 1 safety point！"
	await get_tree().create_timer(2.0).timeout
	
	if data["no_score"] > 0: game_manager.add_Safetypoint()
	elif data["no_score"] < 0: game_manager.sub_Safetypoint()
	
	finish_event()

# --- 5. end and reset ---
func finish_event():
	chest_panel.hide()
	chest_panel.modulate = Color.WHITE 
	game_manager.current_event_index += 1
	is_triggered = false
	# 3. 任务完成，断开按钮连接
	if yes_button.pressed.is_connected(_on_yes_button_pressed):
		yes_button.pressed.disconnect(_on_yes_button_pressed)
	if no_button.pressed.is_connected(_on_no_button_pressed):
		no_button.pressed.disconnect(_on_no_button_pressed)
	
