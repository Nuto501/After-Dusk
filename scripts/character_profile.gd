class_name CharacterProfile
extends Resource

@export var id: String
@export var display_name: String
@export_range(18, 120) var age: int = 18
@export_multiline var bio: String
@export var portrait_base: Texture2D
@export var expressions: Dictionary = {}
@export var affection: int = 0
@export var trust: int = 0

func portrait_for(expression: String) -> Texture2D:
	return expressions.get(expression, portrait_base)
