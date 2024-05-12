extends Node2D


func _ready() -> void:
	$start_timer.start()





func _on_start_timer_timeout() -> void:
	$gamestage/player.start()
