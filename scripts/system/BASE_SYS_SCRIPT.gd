extends Node

var Enabled = false

func _ready():
	pass

func start_script():
	Enabled = true
	set_process(true)