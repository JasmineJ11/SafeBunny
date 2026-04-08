extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	# 确保碰到的是玩家
	if body.has_method("update_checkpoint"):
		print("Player fell! ")
		
		Engine.time_scale = 0.5
		
		# 2. 传送玩家到他记录的重生点
		body.global_position = body.respawn_position
		
		# 3. 非常重要：重置玩家的速度，防止传回来后还带着掉落的惯性
		if "velocity" in body:
			body.velocity = Vector2.ZERO
		
		# 4. 启动计时器恢复时间流速
		timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
