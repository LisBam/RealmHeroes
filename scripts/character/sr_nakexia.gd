extends character_base

func _ready() -> void:
	super._ready()
	skilla_description = "那刻夏a技能"
	skillb_description = "那刻夏b技能"
	skillc_description = "那刻夏c技能"
	skilld_description = "那刻夏d技能"
	skilla_short_desc = "暂无简约描述"
	skillb_short_desc = "暂无简约描述"
	skillc_short_desc = "暂无简约描述"
	skilld_short_desc = "暂无简约描述"

func skilla(enemy,player,enemy_team,player_team):
	super.skilla(enemy,player,enemy_team,player_team)
	enemy.be_damage(damage(5000,"mag",enemy,skilla_element),player,"mag",skilla_element)
	to_damage(damage(5000,"mag",enemy,skilla_element),enemy,"mag",skilla_element)
	attack_skill_animation()
	Signals.to_next_phase.emit()

func skillb(enemy,player,enemy_team,player_team):
	super.skillb(enemy,player,enemy_team,player_team)
	recover(5000)
	tool_skill_animation()
	Signals.to_next_phase.emit()

func skillc(enemy,player,enemy_team,player_team):
	super.skillc(enemy,player,enemy_team,player_team)
	enemy.be_damage(damage(2000,"mag",enemy,skillc_element),player,"mag",skillc_element)
	to_damage(damage(2000,"mag",enemy,skillc_element),enemy,"mag",skillc_element)
	attack_skill_animation()
	Signals.to_next_phase.emit()
	
func skilld(enemy,player,enemy_team,player_team):
	super.skilld(enemy,player,enemy_team,player_team)
	enemy.be_damage(damage(500,"mag",enemy,skilld_element),player,"mag",skilld_element)
	to_damage(damage(500,"mag",enemy,skilld_element),enemy,"mag",skilld_element)
	attack_skill_animation()
	Signals.to_next_phase.emit()
