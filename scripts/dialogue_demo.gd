extends Control

@onready var speaker_label: Label = %Speaker
@onready var dialogue_label: Label = %Dialogue
@onready var choices_box: VBoxContainer = %Choices
@onready var feedback_label: Label = %Feedback
@onready var portrait: TextureRect = %Portrait
@onready var portrait_fallback: Label = %PortraitFallback

var manager := DialogueManager.new()
var affection := 0
var trust := 0

var demo := {
	"start": {
		"speaker": "Sofia",
		"expression": "warm",
		"text": "You finally made it... I wasn't sure you would come.",
		"choices": [
			{
				"text": "I'll stay. I'd like that.",
				"next": "stay",
				"effects": {"affection": 2, "trust": 1},
				"feedback": "Sofia seems genuinely pleased."
			},
			{
				"text": "Depends what you have in mind...",
				"next": "tease",
				"effects": {"affection": 1},
				"feedback": "A playful smile crosses Sofia's face."
			},
			{
				"text": "I should probably get going.",
				"next": "leave",
				"effects": {"trust": -1},
				"feedback": "Sofia becomes a little more guarded."
			}
		]
	},

	"stay": {
		"speaker": "Sofia",
		"expression": "happy",
		"text": "Good. I was hoping you'd say that.",
		"choices": [
			{
				"text": "Stay with her",
				"next": "quiet",
				"effects": {"trust": 1},
				"feedback": "The tension between you eases."
			}
		]
	},

	"tease": {
		"speaker": "Sofia",
		"expression": "amused",
		"text": "Careful. I might actually answer that.",
		"choices": [
			{
				"text": "Smile",
				"next": "quiet",
				"effects": {"affection": 1},
				"feedback": "Sofia holds your gaze for a moment."
			}
		]
	},

	"leave": {
		"speaker": "Sofia",
		"expression": "neutral",
		"text": "All right. Another night, then.",
		"choices": [
			{"text": "Leave", "next": ""}
		]
	},

	"quiet": {
		"speaker": "Sofia",
		"expression": "warm",
		"text": "For once, neither of us needs to rush anywhere.",
		"choices": [
			{"text": "Continue", "next": ""}
		]
	}
}

func _ready() -> void:
	add_child(manager)

	manager.line_changed.connect(_on_line)
	manager.choices_changed.connect(_on_choices)
	manager.relationship_changed.connect(_on_relationship_changed)
	manager.dialogue_finished.connect(_on_finished)

	manager.start(demo)

func _on_line(speaker: String, text: String, expression: String) -> void:
	speaker_label.text = speaker
	dialogue_label.text = text
	feedback_label.text = ""
	_set_portrait(expression)

func _set_portrait(expression: String) -> void:
	var path := "res://art/portraits/sofia/%s.png" % expression

	if ResourceLoader.exists(path):
		portrait.texture = load(path)
		portrait.visible = true
		portrait_fallback.visible = false
	else:
		portrait.texture = null
		portrait.visible = false
		portrait_fallback.visible = true
		portrait_fallback.text = "SOFIA\n" + expression.capitalize()

func _on_choices(choices: Array) -> void:
	for child in choices_box.get_children():
		child.queue_free()

	for i in choices.size():
		var button := Button.new()
		button.text = str(choices[i].get("text", "..."))
		button.custom_minimum_size = Vector2(0, 86)
		button.add_theme_font_size_override("font_size", 25)
		button.pressed.connect(manager.choose.bind(i))
		choices_box.add_child(button)

func _on_relationship_changed(stat: String, amount: int, feedback: String) -> void:
	if stat == "affection":
		affection += amount
	elif stat == "trust":
		trust += amount

	if not feedback.is_empty():
		feedback_label.text = feedback

func _on_finished() -> void:
	dialogue_label.text = "The moment passes into the night."
	feedback_label.text = "End of dialogue demo."

	for child in choices_box.get_children():
		child.queue_free()
