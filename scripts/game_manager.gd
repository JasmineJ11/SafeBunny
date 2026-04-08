extends Node
@onready var score_label: Label = %ScoreLabel
@onready var sms_panel: Panel = %SMSPanel
@onready var notification_sound: AudioStreamPlayer = $NotificationSound
@onready var invite_label: Label = %InviteLabel
@onready var invite_button: Button = %InviteButton
@onready var safety_label: Label = %SafetyLabel
@onready var goal_panel: Panel = %GoalPanel
@onready var goal_label: Label = %GoalLabel
@onready var goal_button: Button = %GoalButton
@onready var yes: TextureRect = %Yes

var score = 0
var helped_kid = 0
var safety_score = 0
var current_event_index = 0 # 记录当前进行到第几个对话 npc
var total_collected = 0


func _ready():
	sms_panel.hide()
	await get_tree().create_timer(3.0).timeout
	show_invitation()
	
# heart score
func add_helped_kid():
	helped_kid += 1;
	print(helped_kid)

func add_point():
	score += 1
	total_collected += 1
	update_score()
	
func sub_point():
	score -= 1
	update_score()
		
func update_score():
	score_label.text = str(score)

# safety score
func add_Safetypoint():
	safety_score += 1
	update_Safetyscore()
	
func sub_Safetypoint():
	safety_score -= 1
	update_Safetyscore()
		
func update_Safetyscore():
	safety_label.text = str(safety_score)


# 邀请玩家参加生日聚会
func show_invitation():
	sms_panel.show()
	
	invite_label.text = "Hi cutie bunny 🐰😊 
		You are on a journey. 🌿✨
		Along the way, you will meet different people..."
	
	if invite_button.pressed.is_connected(_on_invite_button_pressed):
		invite_button.pressed.disconnect(_on_invite_button_pressed)
	
	invite_button.pressed.connect(_advance_invite_text)
	play_notification_sound()
	
var invite_step = 0
func _advance_invite_text():
	invite_step += 1
		
	if invite_step == 1:
		invite_label.text = "Some need help. 🤝💛 
		Some may not be safe. ⚠️🛡️
		Be careful and stay kind. 🦄✨"
	if invite_step == 2:
		invite_label.text = "Ready? 🎒✨\nLet’s share kindness ❤️🌈\nand stay safe together! ☁️✨"
		
	if invite_step == 3:
	
		invite_button.pressed.connect(_on_invite_button_pressed)
	
# 点击确认后隐藏邀请面板
func _on_invite_button_pressed():
	sms_panel.hide()
	
func play_notification_sound():
	if notification_sound:
		notification_sound.play()

#############################################

func give_heart_to_kid():
	score -= 1          # 实时 UI 上减少一颗心
	helped_kid += 1     # 记录送出了一颗心
	update_score()      # 更新左上角的分数显示
#======================================================
var goal_step = 0

func show_game_over():
	goal_panel.show()
	goal_button.show()
	goal_label.text = "🌙 The journey is over...\n"
	goal_label.text += "🥰 But what you did along the way matters.\n\n"
	goal_step = 0
	if goal_button.pressed.is_connected(_on_goal_button_pressed):
		goal_button.pressed.disconnect(_on_goal_button_pressed)
	
	# 点击按钮不再直接重启，而是先执行“翻页”逻辑
	goal_button.pressed.connect(_advance_goal_text)
	
func _advance_goal_text():
	goal_step += 1
	if goal_step == 1:

		goal_label.text = "🛡️ Safety Score: " + str(safety_score) + "\n"
		goal_label.text += "❤️ Collected: " + str(total_collected) + "\n"
		goal_label.text += "🎁 Shared: " + str(helped_kid) + "\n"
		goal_label.text += "✨ Collected + Shared: " + str(total_collected + helped_kid) + " Hearts ✨\n"
		score_label.text = str(total_collected + helped_kid)
	if goal_step == 2:
		goal_label.text = "See? The love you shared didn't disappear.🥰🥰\nIt grew and found its way back to you! ❤️❤️"
		yes.hide()
		goal_button.text = "Play Again"
		
		
	if goal_step == 3:
		goal_button.pressed.connect(_on_goal_button_pressed)
		

# 2. 添加重新开始的函数
func _on_goal_button_pressed():
	get_tree().reload_current_scene() # 重新加载当前场景
	
	
