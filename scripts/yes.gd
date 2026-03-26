extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready():
	# 创建一个无限循环的动画
	var tween = create_tween().set_loops()
	# 0.6秒内放大到 1.1 倍，使用“缓入缓出”让动作更平滑
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.6).set_trans(Tween.TRANS_SINE)
	# 0.6秒内恢复原样
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.6).set_trans(Tween.TRANS_SINE)

	# 别忘了把节点的 Pivot Offset (轴心点) 设为中心，否则它会往右下角放大
	# 在 Inspector -> Control -> Layout -> Pivot Offset 设置
