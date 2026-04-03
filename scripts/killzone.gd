extends Area2D
# 等节点准备好以后，把名字叫 Timer 的子节点抓过来，存进这个变量里。
# :Timer 这个变量只存Timer类型的节点点
# $是 get_node() 的简写。 $Timer：表示在当前节点的子节点中，找一个名字叫 "Timer" 的节点。
@onready var timer: Timer = $Timer


#@onready var attack_panel: Panel = %AttackPanel



func _on_body_entered(body: Node2D) -> void:
	print("You died!")
	Engine.time_scale = 0.5 # slow down the time
	body.get_node("CollisionShape2D").queue_free() #remove the node
	timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
