extends Node
@onready var score_label: Label = %ScoreLabel
@onready var sms_panel: Panel = %SMSPanel
@onready var notification_sound: AudioStreamPlayer = $NotificationSound



var score = 0
var helped_kid = 0

func _ready():
	# 确保游戏开始时弹窗是看不见的
	sms_panel.hide()
	await get_tree().create_timer(3.0).timeout
	show_invitation()
	

func add_helped_kid():
	helped_kid += 1;
	print(helped_kid)


func add_point():
	score += 1
	update_score()
		
func update_score():
	score_label.text = str(score)

# 邀请玩家参加生日聚会
func show_invitation():
	sms_panel.show()
	play_notification_sound()

# 点击确认后隐藏邀请面板
func _on_button_pressed() -> void:
	sms_panel.hide()
	
func play_notification_sound():
	if notification_sound:
		notification_sound.play()

#############################################
