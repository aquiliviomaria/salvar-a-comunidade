extends Node

# Controlador de input que continua activo mesmo com a arvore do jogo pausada.
# Trata da tecla ESC (ui_cancel) para abrir/fechar a pausa e fechar menus.

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	var scene: Node = get_tree().current_scene
	if scene and scene.has_method("handle_cancel"):
		scene.call("handle_cancel")
		get_viewport().set_input_as_handled()
