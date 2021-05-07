extends Spatial

var is_water_on = false

func turn_on_water():
	if !is_water_on:
		$p_water.set_emitting(true)

		is_water_on = true

func turn_off_water():
	if is_water_on:
		$p_water.set_emitting(false)

		is_water_on = false
