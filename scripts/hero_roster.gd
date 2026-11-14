extends RefCounted
class_name HeroRoster

const HERO_ORDER := ["assault", "sniper", "heavy", "medic", "scout"]

const HEROES := {
	"assault": {
		"display_name": "ASSAULT",
		"role": "Penyerang serbaguna",
		"description": "Seimbang untuk garis depan dan duel jarak menengah.",
		"max_hp": 240.0,
		"move_speed": 8.0,
		"attack_damage": 22.0,
		"attack_range": 12.0,
		"attack_cooldown": 0.78
	},
	"sniper": {
		"display_name": "SNIPER",
		"role": "Penembak jarak jauh",
		"description": "Jangkauan dan damage tinggi, tetapi HP lebih rendah.",
		"max_hp": 175.0,
		"move_speed": 7.0,
		"attack_damage": 38.0,
		"attack_range": 22.0,
		"attack_cooldown": 1.35
	},
	"heavy": {
		"display_name": "HEAVY",
		"role": "Tank garis depan",
		"description": "HP besar untuk menahan serangan lawan.",
		"max_hp": 360.0,
		"move_speed": 5.8,
		"attack_damage": 25.0,
		"attack_range": 10.0,
		"attack_cooldown": 1.05
	},
	"medic": {
		"display_name": "MEDIC",
		"role": "Pendukung tim",
		"description": "Unit support dengan daya tahan sedang.",
		"max_hp": 220.0,
		"move_speed": 7.4,
		"attack_damage": 16.0,
		"attack_range": 13.0,
		"attack_cooldown": 0.9
	},
	"scout": {
		"display_name": "SCOUT",
		"role": "Pengintai cepat",
		"description": "Mobilitas tinggi untuk rotasi dan penyergapan.",
		"max_hp": 195.0,
		"move_speed": 10.0,
		"attack_damage": 19.0,
		"attack_range": 11.0,
		"attack_cooldown": 0.68
	}
}

static func get_profile(hero_id: String) -> Dictionary:
	return HEROES.get(hero_id, HEROES["assault"])
