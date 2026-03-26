extends Node
@onready var score_label: Label = %ScoreLabel
@onready var sms_panel: Panel = %SMSPanel


var score = 0;

func _ready():
	# 确保游戏开始时弹窗是看不见的
	sms_panel.hide()

func add_point():
	score += 1
	update_score()
	if score == 5:
		show_invitation()
		
func update_score():
	score_label.text = str(score)

# 邀请玩家参加生日聚会
func show_invitation():
	sms_panel.show()
# 点击确认后隐藏邀请面板
func _on_button_pressed() -> void:
	sms_panel.hide()

#############################################
