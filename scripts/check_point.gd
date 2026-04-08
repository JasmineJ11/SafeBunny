extends Area2D

@onready var checkpoint_sound: AudioStreamPlayer = $AudioStreamPlayer
@onready var update_sound: AudioStreamPlayer = $UpdateSound

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("update_checkpoint"):
		body.update_checkpoint(global_position)
		update_sound.play()
