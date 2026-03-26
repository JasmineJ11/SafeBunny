extends Area2D

# 绑定你在 Inspector 里拖进去的那个面板
@onready var chest_panel: Panel = %ChestPanel

# 这里的变量要根据你 UI 里的名字来改，确保开启了 % 唯一名称
@onready var label = chest_panel.get_node("%ChestLabel") 
@onready var blur_bg = chest_panel.get_node_or_null("%BlurBackground")
@onready var game_manager: Node = %GameManager

@onready var success_sound: AudioStreamPlayer2D = $SuccessSound
@onready var fail_sound: AudioStreamPlayer2D = $FailSound


var is_triggered = false # 确保只触发一次

func _ready():
	# 关键：游戏开始时，强制隐藏面板，防止它一开始就挡住屏幕
	chest_panel.hide()

# --- 1. 玩家撞击宝箱 ---
func _on_body_entered(body):
	
	if body.name == "Player" and not is_triggered:
		is_triggered = true
		start_scam_event()

# --- 2. 开启弹窗 ---
func start_scam_event():
	chest_panel.show()
	if blur_bg: blur_bg.show()
	
	label.text = "🎉 Congratulations! You won €99,999! 💳 Click to claim: www.win-free-99k.top/claim"

# --- 3. 错误路径 (连给 YesButton 的信号) ---
# 注意：在编辑器里把 YesButton 的信号连到这个 TreasureChest 脚本上
func _on_yes_button_pressed():
	# 🎬 诱导
	label.text = "Sending your reward... 💶"
	await get_tree().create_timer(1.5).timeout
	
	# ⚠️ 反转
	if fail_sound: fail_sound.play()
	chest_panel.modulate = Color(0.977, 0.609, 0.6, 1.0) # 面板变淡红
	label.text = "❗ You trusted a fake message!\n❗ Your information was stolen!"
	await get_tree().create_timer(2.5).timeout
	chest_panel.modulate = Color.WHITE # 恢复颜色
	
	label.text = "❗ You lose 1 heart!"
	
	# 💔 扣分（假设 GameManager 是全局脚本）
	game_manager.score -= 1
	game_manager.update_score()
	
	await get_tree().create_timer(3.0).timeout
	# 🐱 猫咪提示
	label.text = "🐱 \"Real rewards don’t try to lure you with money.\""
	await get_tree().create_timer(3.0).timeout
	finish_event()

# --- 4. 正确路径 (连给 NoButton 的信号) ---
func _on_no_button_pressed():
	# 🤔 识别
	label.text = "🤔 Is this reward real?"
	await get_tree().create_timer(2.0).timeout
	
	if success_sound: success_sound.play()
	
	# ❤️ 正反馈
	chest_panel.modulate = Color(0.5, 1, 0.5) # 面板变淡绿
	label.text = "✅ This is a scam!\n✨ You protected your information! You got 1 heart!"
	
	game_manager.score += 1
	game_manager.update_score()
	
	await get_tree().create_timer(4.0).timeout
	chest_panel.modulate = Color.WHITE # 恢复颜色
	# 🐱 猫咪提示
	label.text = "🐱 \"The bigger the reward sounds, the more careful you should be.\""
	
	
	await get_tree().create_timer(4.0).timeout
	finish_event()

# --- 5. 结束并恢复 ---
func finish_event():
	chest_panel.hide()
	if blur_bg: blur_bg.hide()
	chest_panel.modulate = Color.WHITE # 恢复颜色
	
	is_triggered = false
	
	get_tree().paused = false
