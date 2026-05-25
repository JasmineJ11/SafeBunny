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


var score = 0 				# hearts collected
var helped_kid = 0			# hearts given to others
var safety_score = 0		# cybersecurity decision score
var current_event_index = 0 # tracks sequential NPC events
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
		SaveManager.data[player_name] = 0.0 # save local
		print(SaveManager.data.has(player_name))
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
	
# after click, hide panel
func _on_invite_button_pressed():
	sms_panel.hide()
	set_player_paused(false)
	
func play_notification_sound():
	if notification_sound:
		notification_sound.play()

#======================================================
var goal_step = 0

func _get_composite_score(total: int, safety: int) -> float:
	return float(total) * 0.5 + float(safety) * 0.5

func show_game_over():
	goal_panel.show()
	goal_button.show()
	goal_label.text = "🌙 The journey is over...\n"
	goal_label.text += "🥰 But what you did along the way matters.\n\n"
	final_total_score = total_collected + helped_kid
	
	goal_step = 0
	if goal_button.pressed.is_connected(_advance_goal_text):
		goal_button.pressed.disconnect(_advance_goal_text)
	if goal_button.pressed.is_connected(_on_restart_button_pressed):
		goal_button.pressed.disconnect(_on_restart_button_pressed)
	
	# Click button to next text
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
		goal_label.text = "See? The love you shared didn't disappear.🥰🥰
						It grew and found its way back to you! ❤️❤️"
		# yes.hide()
		# goal_button.text = "Next"
		
	if goal_step == 3:
		var composite_score = _get_composite_score(final_total_score, safety_score)
		
		goal_label.text = "Leaderboard (Top 5) 🏆 \n"
		goal_label.text += "Composite = Hearts x 50% + Safety x 50%\n"
		SaveManager.update_score(player_name, composite_score)
		goal_label.text += SaveManager._build_leaderboard_text()
		goal_label.text += "\n\n"
		
		goal_label.text += "⭐ " + player_name + " Personal Best: " + ("%.1f" % SaveManager.data[player_name])
	
		yes.hide()
		goal_button.text = "Play Again"
		if goal_button.pressed.is_connected(_advance_goal_text):
			goal_button.pressed.disconnect(_advance_goal_text)
		if not goal_button.pressed.is_connected(_on_restart_button_pressed):
			goal_button.pressed.connect(_on_restart_button_pressed)
		

# restart game
func _on_restart_button_pressed():
	get_tree().reload_current_scene() # restart scene