extends character_base

func _ready() -> void:
	super._ready()
	skilla_description = "银狼a技能"
	skillb_description = "银狼b技能"
	skillc_description = "银狼c技能"
	skilld_description = "银狼d技能"
	skilla_short_desc = "暂无简约描述"
	skillb_short_desc = "暂无简约描述"
	skillc_short_desc = "暂无简约描述"
	skilld_short_desc = "暂无简约描述"

func skilla(enemy,player,enemy_team,player_team):
	super.skilla(enemy,player,enemy_team,player_team)
	enemy.be_damage(damage(1000,"phy",enemy,skilla_element),player,"phy",skilla_element)
	to_damage(damage(1000,"phy",enemy,skilla_element),enemy,"phy",skilla_element)
	tool_skill_animation()
	Signals.to_next_phase.emit()

func skillb(enemy,player,enemy_team,player_team):
	super.skillb(enemy,player,enemy_team,player_team)
	enemy.be_damage(damage(200,"phy",enemy,skillb_element),player,"phy",skillb_element)
	to_damage(damage(200,"phy",enemy,skillb_element),enemy,"phy",skillb_element)
	attack_skill_animation()
	Signals.to_next_phase.emit()
	
func skillc(enemy,player,enemy_team,player_team):
	super.skillc(enemy,player,enemy_team,player_team)
	enemy.be_damage(damage(2000,"phy",enemy,skillc_element),player,"phy",skillc_element)
	to_damage(damage(2000,"phy",enemy,skillc_element),enemy,"phy",skillc_element)
	attack_skill_animation()
	Signals.to_next_phase.emit()
	
func skilld(enemy,player,enemy_team,player_team):
	super.skilld(enemy,player,enemy_team,player_team)
	enemy.be_damage(damage(2000,"phy",enemy,skilld_element),player,"phy",skilld_element)
	to_damage(damage(2000,"phy",enemy,skilld_element),enemy,"phy",skilld_element)
	attack_skill_animation()
	Signals.to_next_phase.emit()
