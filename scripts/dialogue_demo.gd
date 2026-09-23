extends Control

@onready var speaker_label: Label = %Speaker
@onready var dialogue_label: Label = %Dialogue
@onready var choices_box: VBoxContainer = %Choices
@onready var affection_label: Label = %Affection
@onready var trust_label: Label = %Trust

var manager := DialogueManager.new()
var affection := 0
var trust := 0

var demo := {
	"start": {"speaker":"Sofia","expression":"warm","text":"You finally made it... I wasn't sure you would come.","choices":[
		{"text":"I'll stay. I'd like that.","next":"stay","effects":{"affection":2,"trust":1}},
		{"text":"Depends what you have in mind...","next":"tease","effects":{"affection":1}},
		{"text":"I should probably get going.","next":"leave","effects":{"trust":-1}}]},
	"stay":{"speaker":"Sofia","expression":"happy","text":"Good. I was hoping you'd say that.","choices":[{"text":"Continue","next":""}]},
	"tease":{"speaker":"Sofia","expression":"amused","text":"Careful. I might actually answer that.","choices":[{"text":"Continue","next":""}]},
	"leave":{"speaker":"Sofia","expression":"neutral","text":"All right. Another night, then.","choices":[{"text":"Leave","next":""}]}
}

func _ready() -> void:
	add_child(manager)
	manager.line_changed.connect(_on_line)
	manager.choices_changed.connect(_on_choices)
	manager.relationship_changed.connect(_on_relationship_changed)
	manager.dialogue_finished.connect(_on_finished)
	_update_stats()
	manager.start(demo)

func _on_line(speaker: String, text: String, _expression: String) -> void:
	speaker_label.text = speaker
	dialogue_label.text = text

func _on_choices(choices: Array) -> void:
	for child in choices_box.get_children(): child.queue_free()
	for i in choices.size():
		var button := Button.new()
		button.text = str(choices[i].get("text", "..."))
		button.custom_minimum_size.y = 76
		button.pressed.connect(manager.choose.bind(i))
		choices_box.add_child(button)

func _on_relationship_changed(stat: String, amount: int) -> void:
	if stat == "affection": affection += amount
	elif stat == "trust": trust += amount
	_update_stats()

func _update_stats() -> void:
	affection_label.text = "Affection  %d" % affection
	trust_label.text = "Trust  %d" % trust

func _on_finished() -> void:
	dialogue_label.text = "End of v0.1 dialogue demo."
	for child in choices_box.get_children(): child.queue_free()
