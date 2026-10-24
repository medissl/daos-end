extends SceneTree
const State = preload("res://scripts/cultivation_state.gd")
const Data = preload("res://scripts/chapter_data.gd")
const Combat = preload("res://scripts/combat.gd")
func _initialize() -> void:
	var report = {}
	for arts in [["sword","flame"],["ward","flame"],["river","flame"]]:
		var wins = []
		for method in ["azure","iron"]:
			for robe in ["stoneweave_robe","river_silk","traveller_robe"]:
				for charm in ["bone_ring","mystic_gourd","jade_pendant"]:
					var s = State.new()
					s.realm = "Foundation Establishment"
					s.primary = method
					s.mastery = {"azure":1,"iron":1}
					s.combat_mastery = {"sword":1,"flame":1,"ward":1,"river":1}
					s.combat_slots = arts
					s.inventory = {"pine_sword":1,robe:1,charm:1}
					s.equipment = {"weapon":"pine_sword","robe":robe,"artifact":charm}
					s.core_prepared = true
					var battle = Combat.begin(Data.stats(s,{"core":true}),Data.all().core,{"core":true})
					Combat.advance(battle,90)
					if battle.outcome=="win": wins.append({"method":method,"robe":robe,"charm":charm,"seconds":battle.ticks*.05,"hp":battle.hp})
			report[str(arts)] = wins
		print(arts," wins: ",wins)
	FileAccess.open("res://docs/living-dao/CORE_APPROACHES.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	quit()
