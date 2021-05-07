extends "res://scripts/level_base.gd"


func _ready():
	pass

func start():
	gui.show_effect("noise")

func show_monsters():
	get_tree().get_nodes_in_group("stage_1_1_monster")[0].get_node("AnimationPlayer").play('horror_appear', -1, 2.4)
	get_tree().get_nodes_in_group("smoking_face")[0].show()
