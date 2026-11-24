class_name Interactable
extends Area2D
## Anything Violet can inspect or talk to. Put it on collision layer 2 (the scene does
## this). Set dialogue_file for a conversation, or inspect_lines for simple narration.

signal interacted(by: Node)

@export_file("*.json") var dialogue_file: String = ""
@export var inspect_lines: PackedStringArray = PackedStringArray()
@export var prompt_text: String = ""


func get_prompt_text() -> String:
	return prompt_text if not prompt_text.is_empty() else "Inspect: %s" % name


func interact(by: Node) -> void:
	interacted.emit(by)
	if dialogue_file != "":
		Dialogue.start_from_file(dialogue_file)
	elif not inspect_lines.is_empty():
		Dialogue.start_narration(inspect_lines)
