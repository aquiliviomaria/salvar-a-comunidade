extends Node

const TYPES := {
	"NPC_HOMEM_FORMAL": {
		"sex": "Homem",
		"clothing": "Roupa formal",
		"shirt_color": Color(0.86, 0.86, 0.78),
		"pants_color": Color(0.12, 0.16, 0.22),
		"accent_color": Color(0.08, 0.28, 0.52),
		"hair_scale": Vector3(0.95, 0.6, 0.88)
	},
	"NPC_HOMEM_INFORMAL": {
		"sex": "Homem",
		"clothing": "T-shirt e calcas",
		"shirt_color": Color(0.9, 0.54, 0.18),
		"pants_color": Color(0.18, 0.23, 0.34),
		"accent_color": Color(0.08, 0.28, 0.52),
		"hair_scale": Vector3(1.0, 0.65, 0.9)
	},
	"NPC_MULHER_CAPULANA": {
		"sex": "Mulher",
		"clothing": "Capulana",
		"shirt_color": Color(0.82, 0.22, 0.38),
		"pants_color": Color(0.22, 0.25, 0.36),
		"accent_color": Color(0.16, 0.64, 0.5),
		"hair_scale": Vector3(1.12, 0.82, 1.06)
	},
	"NPC_MULHER_INFORMAL": {
		"sex": "Mulher",
		"clothing": "Roupa informal",
		"shirt_color": Color(0.42, 0.34, 0.78),
		"pants_color": Color(0.18, 0.16, 0.24),
		"accent_color": Color(0.95, 0.56, 0.18),
		"hair_scale": Vector3(1.08, 0.8, 1.0)
	},
	"NPC_CRIANCA": {
		"sex": "Crianca",
		"clothing": "Roupa escolar",
		"shirt_color": Color(0.96, 0.78, 0.18),
		"pants_color": Color(0.18, 0.28, 0.46),
		"accent_color": Color(0.2, 0.58, 0.82),
		"hair_scale": Vector3(0.88, 0.58, 0.82),
		"scale": Vector3(0.82, 0.82, 0.82)
	},
	"NPC_IDOSO": {
		"sex": "Idoso",
		"clothing": "Roupa simples",
		"shirt_color": Color(0.66, 0.66, 0.58),
		"pants_color": Color(0.18, 0.18, 0.16),
		"accent_color": Color(0.45, 0.36, 0.25),
		"hair_scale": Vector3(0.9, 0.62, 0.86)
	}
}

const CITIZENS := [
	{
		"name": "Maria",
		"type": "NPC_MULHER_CAPULANA",
		"age": 34,
		"profession": "Agricultora",
		"home": "Casa Familiar",
		"state": "Precisa de agua",
		"dialogue": "A nossa comunidade esta com pouca agua segura.",
		"mission_id": "find_water",
		"position": Vector3(-4, 0, 4)
	},
	{
		"name": "Antonio",
		"type": "NPC_HOMEM_FORMAL",
		"age": 41,
		"profession": "Enfermeiro",
		"home": "Unidade Sanitaria",
		"state": "Precisa de medicamentos",
		"dialogue": "A unidade sanitaria precisa de medicamentos.",
		"mission_id": "hospital",
		"position": Vector3(12, 0, 2)
	},
	{
		"name": "Mateus",
		"type": "NPC_HOMEM_INFORMAL",
		"age": 29,
		"profession": "Carpinteiro",
		"home": "Casa Norte",
		"state": "Quer proteger a floresta",
		"dialogue": "A floresta protege as nossas casas do vento e da erosao.",
		"mission_id": "protect_forest",
		"position": Vector3(-5, 0, -3)
	},
	{
		"name": "Nando",
		"type": "NPC_CRIANCA",
		"age": 12,
		"profession": "Estudante",
		"home": "Casa Sul",
		"state": "Viu uma emergencia",
		"dialogue": "Ha uma emergencia perto do centro comunitario.",
		"mission_id": "emergency",
		"position": Vector3(5, 0, -1)
	},
	{
		"name": "Sofia",
		"type": "NPC_MULHER_INFORMAL",
		"age": 26,
		"profession": "Comerciante",
		"home": "Mercado",
		"state": "Organiza recursos",
		"dialogue": "As familias precisam receber recursos com ordem.",
			"mission_id": "community_challenge",
		"position": Vector3(1, 0, -5)
	},
	{
		"name": "Bento",
		"type": "NPC_IDOSO",
		"age": 67,
		"profession": "Lider comunitario",
		"home": "Centro Comunitario",
		"state": "Conhece os caminhos",
		"dialogue": "Alguns caminhos sao mais seguros para transportar recursos.",
		"mission_id": "safe_path",
		"position": Vector3(20, 0, 10)
	},
	{
		"name": "Lina",
		"type": "NPC_MULHER_CAPULANA",
		"age": 38,
		"profession": "Pescadora",
		"home": "Casa Nova",
		"state": "Protege a zona do rio",
		"dialogue": "O rio e a praia precisam ficar limpos e seguros.",
			"mission_id": "protect_forest",
		"position": Vector3(38, 0, 38)
	},
	{
		"name": "Fatima",
		"type": "NPC_MULHER_CAPULANA",
		"age": 52,
		"profession": "Avo da comunidade",
		"home": "Casa Familiar",
		"state": "Cuida das criancas",
		"dialogue": "As nossas criancas precisam de escola e de um futuro melhor.",
		"mission_id": "safe_path",
		"position": Vector3(-14, 0, 18)
	},
	{
		"name": "Jonas",
		"type": "NPC_CRIANCA",
		"age": 9,
		"profession": "Estudante",
		"home": "Casa Norte",
		"state": "Quer aprender",
		"dialogue": "Quero ir a escola mas o caminho e perigoso!",
		"mission_id": "safe_path",
		"position": Vector3(3, 0, -8)
	},
	{
		"name": "Bernardo",
		"type": "NPC_IDOSO",
		"age": 72,
		"profession": "Agricultor reformado",
		"home": "Casa Sul",
		"state": "Preocupado com a colheita",
		"dialogue": "Este ano a colheita esta fraca. Precisamos de agua para os campos.",
		"mission_id": "find_water",
		"position": Vector3(-30, 0, -22)
	},
	{
		"name": "Celeste",
		"type": "NPC_MULHER_INFORMAL",
		"age": 31,
		"profession": "Professora",
		"home": "Escola",
		"state": "Precisa de material escolar",
		"dialogue": "As criancas precisam de cadernos e livros para aprender.",
			"mission_id": "safe_path",
		"position": Vector3(28, 0, -14)
	},
	{
		"name": "Custodio",
		"type": "NPC_HOMEM_INFORMAL",
		"age": 44,
		"profession": "Pastor",
		"home": "Pastos",
		"state": "Os animais precisam de agua",
		"dialogue": "Os bois e cabritos estao com sede. Precisamos de agua para os pastos.",
		"mission_id": "feed_animals",
		"position": Vector3(-33, 0, -20)
	},
	{
		"name": "Rosa",
		"type": "NPC_MULHER_CAPULANA",
		"age": 48,
		"profession": "Responsavel do armazem",
		"home": "Armazem de Madeira",
		"state": "Tem alimentos para distribuir",
		"dialogue": "Temos alimentos no armazem mas as familias precisam que alguem os distribua.",
		"mission_id": "distribute_food",
		"position": Vector3(24, 0, 22)
	}
]


func get_citizens() -> Array:
	return CITIZENS.duplicate(true)


func get_type_data(type_id: String) -> Dictionary:
	return TYPES.get(type_id, TYPES.NPC_HOMEM_INFORMAL).duplicate(true)
