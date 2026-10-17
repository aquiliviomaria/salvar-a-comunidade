extends Area3D

@export var mission_id := "emergency"
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


func interact(_player: Node) -> String:
	if completed:
		return "✅ Esta tarefa comunitaria ja foi concluida. Procura outra area na comunidade."
	completed = true
	if direct_community_task:
		MissionManager.complete_community_task(title, health_reward, xp_reward)
		ResourceManager.add_money(money_reward)
	else:
		MissionManager.progress_action(mission_id, 1)
	if has_node("Label3D"):
		$Label3D.text = "✅ %s" % title
	SoundManager.play_success()
	return "%s %s\n💰 +%d MT   ⭐ +%d XP" % [icon, message, money_reward, xp_reward]
