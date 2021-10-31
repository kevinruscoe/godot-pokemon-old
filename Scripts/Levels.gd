extends Node

func _ready():
	get_tree().get_nodes_in_group("player")[0].position = $SpawnPoint.position
