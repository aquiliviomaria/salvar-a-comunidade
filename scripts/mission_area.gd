extends Area3D

@export var mission_id := "emergency"
@export var objective_id := ""
@export var message := "Ajuda prestada na area de emergencia."
@export var title := "Missao comunitaria"
@export var health_reward := 8
@export var xp_reward := 45
@export var money_reward := 50
@export var direct_community_task := true
@export var icon := "🤝"

var completed := false


func _ready() -> void:
	add_to_group("interactable")
	if has_node("Label3D"):
		$Label3D.text = "%s %s" % [icon, title]


func get_prompt(_player: Node) -> String:
	if completed:
		return ""
	return "E — Ajudar"


func interact(_player: Node) -> String:
	if completed:
		return "✅ Esta tarefa comunitaria ja foi concluida. Procura outra area na comunidade."

	if direct_community_task:
		completed = true
		MissionManager.complete_community_task(title, health_reward, xp_reward)
		ResourceManager.add_money(money_reward)
		_show_completed_visual()
		SoundManager.play_success()
		return "%s %s\n💰 +%d MT   ⭐ +%d XP" % [icon, message, money_reward, xp_reward]

	# Area ligada a um objectivo de missao: so conta com a missao activa.
	var target_objective: String = objective_id if objective_id != "" else mission_id
	if MissionManager.current_mission != mission_id:
		return "Aceita primeiro a missao correspondente com um habitante da comunidade."
	if MissionManager.is_objective_done(mission_id, target_objective):
		completed = true
		_show_completed_visual()
		return "✅ %s" % message
	completed = true
	MissionManager.progress_action(target_objective, 1)
	_show_completed_visual()
	SoundManager.play_collect()
	return "%s %s" % [icon, message]


func _show_completed_visual() -> void:
	if has_node("Label3D"):
		$Label3D.text = "✅ %s" % title
