class_name Door
extends Interactable
## Interact to (optionally show inspect_lines, then) change to target_scene.

@export_file("*.tscn") var target_scene: String = ""


func interact(by: Node) -> void:
	interacted.emit(by)
	if not inspect_lines.is_empty():
		Dialogue.start_narration(inspect_lines)
		await Dialogue.dialogue_finished
	if target_scene != "":
		SceneManager.change_scene(target_scene)
