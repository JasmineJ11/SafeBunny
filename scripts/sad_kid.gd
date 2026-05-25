extends Area2D
@onready var love_button: Button = %LoveButton
@onready var game_manager: Node = %GameManager
@onready var anim: AnimatedSprite2D = $SadKidSprite
@onready var happy_sound: AudioStreamPlayer2D = $happySound
@onready var confetti_particles: GPUParticles2D = $ConfettiParticles

var is_happy = false

func _ready():
	anim.play("sad")
	love_button.hide()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not is_happy:
		love_button.show()
		love_button.pressed.connect(_on_love_button_pressed)
		await get_tree().create_timer(2.5).timeout
		love_button.hide()

func _on_love_button_pressed() -> void:
	if is_happy: return
	if happy_sound: happy_sound.play()
	is_happy = true
	love_button.hide()
	anim.play("happy")
	if confetti_particles:
		confetti_particles.restart()
	game_manager.give_heart_to_kid()