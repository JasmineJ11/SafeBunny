extends Node
@onready var score_label: Label = %ScoreLabel
@onready var sms_panel: Panel = %SMSPanel
@onready var name_line_edit: LineEdit = %NameLineEdit
@onready var notification_sound: AudioStreamPlayer = $NotificationSound
@onready var invite_label: Label = %InviteLabel
@onready var invite_button: Button = %InviteButton
@onready var safety_label: Label = %SafetyLabel
@onready var goal_panel: Panel = %GoalPanel
@onready var goal_label: Label = %GoalLabel
@onready var goal_button: Button = %GoalButton
@onready var yes: TextureRect = %Yes
@onready var player: Node = get_parent().get_node_or_null("Player")

var score = 0
var helped_kid = 0
var safety_score = 0
var current_event_index = 0 # 记录当前进行到第几个对话 npc
var total_collected = 0

var invite_step = 0
var waiting_for_name = true
var player_name = ""
var final_total_score = 0

# pause role when typing
func set_player_paused(paused: bool) -> void:
	if player:
		player.set("is_paused", paused)


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

# for sad_kid.gd
func give_heart_to_kid():
	score -= 1          
	helped_kid += 1     
	update_score()     

#======================================================


# 邀请玩家参加生日聚会
func show_invitation():
	sms_panel.show()
	name_line_edit.hide()
	
	waiting_for_name = true
	invite_step = 0

	invite_label.text = "Hi cutie bunny 🐰😊 what's your name?"
	name_line_edit.show()
	set_player_paused(true)
	
	if invite_button.pressed.is_connected(_on_invite_button_pressed):
		invite_button.pressed.disconnect(_on_invite_button_pressed)
	
	invite_button.pressed.connect(_advance_invite_text)
	play_notification_sound()

# when click okay button
func _advance_invite_text():

	# get user name 
	if waiting_for_name:
		var typed_name := name_line_edit.text.strip_edges()
		if typed_name.is_empty():
			invite_label.text = "Please tell me your name."
			return
		player_name = typed_name
		SaveManager.set_active_player_name(player_name) # 存本地
		#
		print(SaveManager.get_active_player_name())
		name_line_edit.hide()
		waiting_for_name = false

		invite_label.text = "Hi " + player_name + "~❤️ You are on a journey. 🌿✨\nAlong the way, you will meet different people..."
		return

	invite_step += 1
		
	if invite_step == 1:
		invite_label.text = "Some need help. 🤝💛 
		Some may not be safe. ⚠️🛡️
		Be careful and stay kind. 🦄✨"
	if invite_step == 2:
		invite_label.text = "Ready? ✨\nLet’s share kindness ❤️\nand stay safe together! ☁️✨🌈"
		
	if invite_step == 3:
	
		invite_button.pressed.connect(_on_invite_button_pressed)
	
# 点击确认后隐藏邀请面板
func _on_invite_button_pressed():
	sms_panel.hide()
	set_player_paused(false)
	
func play_notification_sound():
	if notification_sound:
		notification_sound.play()

 
#======================================================
var goal_step = 0








func show_game_over():
	goal_panel.show()
	goal_button.show()
	goal_label.text = "🌙 The journey is over...\n"
	goal_label.text += "🥰 But what you did along the way matters.\n\n"
	final_total_score = total_collected + helped_kid

	var current_name := SaveManager.get_active_player_name()
	if not current_name.is_empty():
		SaveManager.record_result(
			current_name,
			final_total_score,
			safety_score,
			helped_kid,
			total_collected
		)
	
	goal_step = 0
	if goal_button.pressed.is_connected(_advance_goal_text):
		goal_button.pressed.disconnect(_advance_goal_text)
	if goal_button.pressed.is_connected(_on_restart_button_pressed):
		goal_button.pressed.disconnect(_on_restart_button_pressed)
	
	# 点击按钮不再直接重启，而是先执行“翻页”逻辑
	goal_button.pressed.connect(_advance_goal_text)
	
func _advance_goal_text():
	goal_step += 1
	if goal_step == 1:

		goal_label.text = "🛡️ Safety Score: " + str(safety_score) + "\n"
		goal_label.text += "❤️ Collected: " + str(total_collected) + "\n"
		goal_label.text += "🎁 Shared: " + str(helped_kid) + "\n"
		goal_label.text += "✨ Collected + Shared: " + str(final_total_score) + " Hearts ✨\n"
		score_label.text = str(final_total_score)

	if goal_step == 2:
		goal_label.text = "See? The love you shared didn't disappear.🥰🥰\nIt grew and found its way back to you! ❤️❤️"
		# yes.hide()
		# goal_button.text = "Next"
		
	if goal_step == 3:
		var current_name := SaveManager.get_active_player_name()
		var best := SaveManager._get_personal_best(current_name)
		goal_label.text = "Leaderboard (Top 5) 🏆 \n"
		goal_label.text += "Composite = Hearts x 50% + Safety x 50%\n"
		goal_label.text += SaveManager._build_leaderboard_text(5)
		goal_label.text += "\n\n"
		if current_name.is_empty():
			goal_label.text += "⭐ Personal Best: Please enter your name at start."
		else:
			goal_label.text += "⭐ " + current_name + " Personal Best: " + ("%.1f" % best)
	
		yes.hide()
		goal_button.text = "Play Again"
		if goal_button.pressed.is_connected(_advance_goal_text):
			goal_button.pressed.disconnect(_advance_goal_text)
		if not goal_button.pressed.is_connected(_on_restart_button_pressed):
			goal_button.pressed.connect(_on_restart_button_pressed)
		

# 2. 添加重新开始的函数
func _on_restart_button_pressed():
	get_tree().reload_current_scene() # 重新加载当前场景
	
	
