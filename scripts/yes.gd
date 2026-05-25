extends TextureRect
# Inspector -> Control -> Layout -> Pivot Offset - central
# Called when the node enters the scene tree for the first time.
# Make the 'yes' button pulse (grow/shrink like breathing).

func _ready():
	var tween = create_tween().set_loops()
	# 0.6s, 1.1 times the size
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.6).set_trans(Tween.TRANS_SINE)
	# 0.6s, back to original size
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.6).set_trans(Tween.TRANS_SINE)