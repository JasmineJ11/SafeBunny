extends Area2D


@onready var bully_panel: Panel = %BullyPanel
@onready var bully_label: Label = %BullyLabel
@onready var btn_l: Button = %ButtonL
@onready var btn_m: Button = %ButtonM
@onready var btn_r: Button = %ButtonR
@onready var game_manager: Node = %GameManager
@onready var success_sound: AudioStreamPlayer2D = $SuccessSound
@onready var fail_sound: AudioStreamPlayer2D = $FailSound


var dialogue_data = {
	0: {
		"text": "📱 You received a message!",
		"options": ["📖 Read now", "", ""],
		"correct": 1 
	},
	1: {
		"text": "👾： Haha… you look so weird 😒\nWhy are you even here?",
		"options": ["😡 Insult back", "😢 Feel hurt and stop", "✨ Ignore and keep going"],
		"correct": 2, 
		"feedback": [
			"🐱 Fighting back only makes it worse.\n💛 Stay calm. ",
			"🐱 Their words don’t define you.\n🌟 You are enough."
		]
	},
	2: {
		"text": "👾： No one likes you 😏\nWhy don’t you just leave?",
		"options": ["😡 Reply angrily", "😟 Ask if it's true",  "✨ Ignore and talk to a trusted adult"],
		"correct": 2,
		"feedback": [
			"🐱 Anger won’t help here.\n🛡️ Protect your energy. ",
			"🐱 Don’t look for approval from someone who hurts you.\n💛 You deserve better. "
		]
	},
	3: {
		"text": "👾： ANSWER ME NOW!! 😡\nWhy are you ignoring me?!",
		"options": ["😢 Keep explain", "😡 Fight back", "✨ Screenshot, report and block"],
		"correct": 2, 
		"feedback": [
			"🐱 You don’t need to explain yourself.\n💛 Stay safe.",
			"🐱 Don’t let them control your emotions.\n📸 Keep evidence instead."
		]
	}
}

var current_round = 0
var is_triggered = false

func _ready():
	bully_panel.hide()


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not is_triggered:
		is_triggered = true
		current_round = 0
		show_round()
		game_manager.play_notification_sound()
		


func show_round():
	bully_panel.show()
	var data = dialogue_data[current_round]
	bully_label.text = data["text"]
	
	if current_round == 0:
		# 开场只显示第一个按钮
		btn_l.show(); btn_r.hide(); btn_m.hide()
		btn_l.text = data["options"][0]
	else:
		# 正式环节显示三个按钮
		btn_l.show(); btn_m.show(); btn_r.show()
		btn_l.text = data["options"][0]
		btn_m.text = data["options"][1]
		btn_r.text = data["options"][2]
		
		
# ---  信号连接 ---
func _on_button_l_pressed(): _on_button_pressed(0)
func _on_button_m_pressed(): _on_button_pressed(1)
func _on_button_r_pressed(): _on_button_pressed(2)

# --- 5. 按钮点击统一处理 ---
func _on_button_pressed(index: int):
	var data = dialogue_data[current_round]
	
	# 开场
	if current_round == 0:
		current_round = 1
		show_round()
		return
	
	# 正式判断
	if index == data["correct"]:
		handle_correct()
	else:
		handle_wrong(index)

# --- 正确 ---
func handle_correct():
	if success_sound: success_sound.play()
	bully_label.text = "🚨 This is online harassment!
	✨ You protected yourself!
	🛡️ You got 1 safety point"
	game_manager.add_Safetypoint()
	hide_buttons()
	await get_tree().create_timer(3.0).timeout
	if current_round < 3:
		current_round += 1
		show_round()
	else:
		finish_event()

# --- 错误 ---
func handle_wrong(index: int):
	if fail_sound: fail_sound.play()
	hide_buttons()
	
	var feedback_text = dialogue_data[current_round]["feedback"][index]
	bully_label.text = feedback_text
	await get_tree().create_timer(3).timeout
	bully_label.text = "❗ You lose 1 safety point. 
	✨ Try again!"
	game_manager.sub_Safetypoint()
	
	await get_tree().create_timer(1.5).timeout
	show_round() # 循环：让玩家重新选这一轮

func hide_buttons():
	btn_l.hide(); btn_m.hide(); btn_r.hide()

func finish_event():
	bully_label.text = "💛 You stayed calm and strong \n✨ The bully lost their power."
	await get_tree().create_timer(3.0).timeout
	bully_label.text = "🛡️ Remember:\n✨ Ignore → Tell a trusted adult → Protect yourself "
	await get_tree().create_timer(4).timeout
	bully_panel.hide()
	is_triggered = true


	
