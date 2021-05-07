extends Control


func _ready():
	pass

func show_effect(_eff_name):
	for eff_n in get_node("effects").get_children():
		eff_n.hide()
		
	get_node("effects/" + _eff_name).show()
