class_name DialogueManager
extends Node

signal line_changed(speaker: String, text: String, expression: String)
signal choices_changed(choices: Array)
signal relationship_changed(stat: String, amount: int)
signal dialogue_finished

var dialogue: Dictionary = {}
var current_id := ""

func start(data: Dictionary, start_id := "start") -> void:
	dialogue = data
	show_node(start_id)

func show_node(node_id: String) -> void:
	if not dialogue.has(node_id):
		dialogue_finished.emit()
		return
	current_id = node_id
	var node: Dictionary = dialogue[node_id]
	line_changed.emit(str(node.get("speaker", "")), str(node.get("text", "")), str(node.get("expression", "neutral")))
	choices_changed.emit(node.get("choices", []))

func choose(index: int) -> void:
	var choices: Array = dialogue[current_id].get("choices", [])
	if index < 0 or index >= choices.size():
		return
	var choice: Dictionary = choices[index]
	var effects: Dictionary = choice.get("effects", {})
	for stat in effects:
		relationship_changed.emit(str(stat), int(effects[stat]))
	var next_id := str(choice.get("next", ""))
	if next_id.is_empty():
		dialogue_finished.emit()
	else:
		show_node(next_id)
