extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	# make sure player enterd
	if body.has_method("update_checkpoint"):
		print("Player fell! ")
		
		Engine.time_scale = 0.5
		
		# 2. send respawn position
		body.global_position = body.respawn_position
		
		# 3. reset velocity
		if "velocity" in body:
			body.velocity = Vector2.ZERO
		
		timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0