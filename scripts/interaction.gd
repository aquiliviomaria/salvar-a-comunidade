extends Node

static func describe_prompt(target: Object) -> String:
	if target and target.has_method("interact"):
		return "Prima E para interagir."
	return ""
