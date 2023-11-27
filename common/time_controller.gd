extends Node

signal time_scaling_done
signal hitstop_done

func scale_time(new_time_scale: float, transition_time := 0.0) -> void:
	if transition_time <= 0:
		Engine.time_scale = new_time_scale
		time_scaling_done.emit()
		return
		
	var timer := get_tree().create_timer(transition_time, true, false, true)
	
	var starting_time_scale := Engine.time_scale
	while timer.time_left > 0 and Engine.time_scale > 0:
		Engine.time_scale = lerp(starting_time_scale, new_time_scale, (transition_time - timer.time_left) / transition_time)
		await get_tree().process_frame
	Engine.time_scale = new_time_scale
	
	time_scaling_done.emit()


func hitstop(duration: float) -> void:
	get_tree().paused = true
	await get_tree().create_timer(duration, true, false, true).timeout
	get_tree().paused = false
	hitstop_done.emit()
