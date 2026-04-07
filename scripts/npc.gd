extends Area2D


@onready var chest_panel: Panel = %ChestPanel

@onready var label = chest_panel.get_node("%ChestLabel") 
@onready var blur_bg = chest_panel.get_node_or_null("%BlurBackground")
@onready var game_manager: Node = %GameManager

@onready var success_sound: AudioStreamPlayer2D = $SuccessSound
@onready var fail_sound: AudioStreamPlayer2D = $FailSound

@onready var yes_button: Button = %YesButton
@onready var no_button: Button = %NoButton


var is_triggered = false 

func _ready():
	# 关键：游戏开始时，强制隐藏面板，防止它一开始就挡住屏幕 hide from begining
	chest_panel.hide()

# --- 1. player touch the chest ---
func _on_body_entered(body):
	if body.name == "Player" and not is_triggered:
		is_triggered = true
		start_scam_event()

# --- 2. start the window ---
func start_scam_event():
	chest_panel.show()
	
		# 如果已经连了，先断开（防止双重连接）
	if yes_button.pressed.is_connected(_on_yes_button_pressed):
		yes_button.pressed.disconnect(_on_yes_button_pressed)
	if no_button.pressed.is_connected(_on_no_button_pressed):
		no_button.pressed.disconnect(_on_no_button_pressed)
		
	# 现在只连这一个脚本的函数
	yes_button.pressed.connect(_on_yes_button_pressed)
	no_button.pressed.connect(_on_no_button_pressed)
	
	
	game_manager.play_notification_sound()
	if blur_bg: blur_bg.show()
	yes_button.show()
	no_button.show()
	label.text = "Hi! 😊
What’s your home address?
I want to send you a gift! 🎁"

# --- 3. click YES ---
# 在编辑器里把 YesButton 的信号连到这个 TreasureChest 脚本上
func _on_yes_button_pressed():
	# scam
	yes_button.hide()
	no_button.hide()

	if fail_sound: fail_sound.play()
	chest_panel.modulate = Color(0.977, 0.609, 0.6, 1.0) # change color
	label.text = "❗ That’s dangerous! 
	⚠️ Your home address is private information."
	await get_tree().create_timer(2.5).timeout
	chest_panel.modulate = Color.WHITE # change color back
	
	label.text = "🛡️ You lose 1 safety point!"
	await get_tree().create_timer(3.0).timeout
	
	# lose 1 point
	game_manager.sub_Safetypoint()
	
	finish_event()

# --- 4. Click NO ---
func _on_no_button_pressed():
	yes_button.hide()
	no_button.hide()
	if success_sound: success_sound.play()
	
	# feedback
	chest_panel.modulate = Color(0.5, 1, 0.5) # change color to green
	label.text = "Good job! 👍
	Never share your home address with strangers! !"
	await get_tree().create_timer(4.0).timeout
	chest_panel.modulate = Color.WHITE 
	label.text = "🛡️ You got 1 safety point"
	await get_tree().create_timer(4.0).timeout
	
	game_manager.add_Safetypoint()
	
	finish_event()

# --- 5. end and reset ---
func finish_event():
	chest_panel.hide()
	if blur_bg: blur_bg.hide()
	chest_panel.modulate = Color.WHITE 
	
	is_triggered = false
	# 3. 任务完成，断开按钮连接
	if yes_button.pressed.is_connected(_on_yes_button_pressed):
		yes_button.pressed.disconnect(_on_yes_button_pressed)
	if no_button.pressed.is_connected(_on_no_button_pressed):
		no_button.pressed.disconnect(_on_no_button_pressed)
	
	get_tree().paused = false
