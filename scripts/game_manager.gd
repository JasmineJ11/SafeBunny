extends Node
@onready var score_label: Label = %ScoreLabel
@onready var sms_panel: Panel = %SMSPanel
@onready var notification_sound: AudioStreamPlayer = $NotificationSound
@onready var invite_label: Label = %InviteLabel




var score = 0
var helped_kid = 0
var safety_score

func _ready():
	# 确保游戏开始时弹窗是看不见的
	sms_panel.hide()
	await get_tree().create_timer(3.0).timeout
	show_invitation()
	
# heart score
func add_helped_kid():
	helped_kid += 1;
	print(helped_kid)

func add_point():
	score += 1
	update_score()
	
func sub_point():
	score -= 1
	update_score()
		
func update_score():
	score_label.text = str(score)

# safety score

# 邀请玩家参加生日聚会
func show_invitation():
	sms_panel.show()
	invite_label.text = "It's March 25th! You're coming to my birthday party, right? 🎂✨"
	#say(invite_label.text)
	play_notification_sound()

# 点击确认后隐藏邀请面板
func _on_button_pressed() -> void:
	sms_panel.hide()
	
func play_notification_sound():
	if notification_sound:
		notification_sound.play()

#############################################
# pitch: 音调 (0.0 到 2.0，默认 1.0)
# rate: 语速 (0.0 到 10.0，默认 1.0)
#func say(text: String, pitch: float = 3, rate: float = 1.2):
	#DisplayServer.tts_stop()
	#DisplayServer.tts_speak(text, "", 200, pitch, rate)
	#print("TTS Reading: ", text)
	
