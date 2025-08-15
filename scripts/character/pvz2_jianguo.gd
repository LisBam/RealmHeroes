extends character_base

func _ready() -> void:
	super._ready()
	tags.append("植物")
	skilla_description = "坚果拥有坚硬的外壳，立即获得800点护盾。"
	skillb_description = "进行光合作用，立即恢复10点能量，并回复100点HP。"
	skillc_description = "果壳碎裂，消耗所有护盾，对目标造成200威力的木属性物伤，每消耗1点护盾该威力+1.5。"
	skilld_description = "坚果周围围绕3个属性的坚果核，对敌方造成火金水属性的三段250威力的物伤。"
	skilla_short_desc = "加盾"
	skillb_short_desc = "回能回血"
	skillc_short_desc = "消耗盾转化为物伤"
	skilld_short_desc = "三段不同属性物伤"

func skilla(enemy,player,enemy_team,player_team):
	super.skilla(enemy,player,enemy_team,player_team)
	add_shield(800)
	tool_skill_animation()
	Signals.to_next_phase.emit()

func skillb(enemy,player,enemy_team,player_team):
	super.skillb(enemy,player,enemy_team,player_team)
	recover_energy(10)
	recover(100)
	tool_skill_animation()
	Signals.to_next_phase.emit()
	
func skillc(enemy,player,enemy_team,player_team):
	super.skillc(enemy,player,enemy_team,player_team)
	var lose_shield = shield
	remove_shield(lose_shield)
	var add_damage = lose_shield * 1.5
	be_and_to_damage(damage(200+add_damage,"phy",enemy,skillc_element),enemy,player,"phy",skillc_element)
	attack_skill_animation()
	Signals.to_next_phase.emit()
	
func skilld(enemy,player,enemy_team,player_team):
	super.skilld(enemy,player,enemy_team,player_team)
	be_and_to_damage(damage(250,"phy",enemy,"fire"),enemy,player,"phy","fire")
	be_and_to_damage(damage(250,"phy",enemy,"metal"),enemy,player,"phy","metal")
	be_and_to_damage(damage(250,"phy",enemy,"water"),enemy,player,"phy","water")
	attack_skill_animation()
	Signals.to_next_phase.emit()

func refresh_ai(enemy,player,enemy_team,player_team):
	await super.refresh_ai(enemy,player,enemy_team,player_team)
	
	ai.skills[1].recover_shield = 800
	#盾还能打伤害，提高收益
	ai.skills[1].strategy_value_count = ai.skills[1].recover_shield*1.3
	
	ai.skills[2].recover_hp = 100
	ai.skills[2].recover_energy = 10
	
	add_damage_element(3,skillc_element)
	ai.skills[3].damage_count = 200 + shield*1.5
	ai.skills[3].value -= shield
	
	add_damage_element(4,"fire")
	add_damage_element(4,"mental")
	add_damage_element(4,"water")
	ai.skills[4].damage_count = 250*3
	
	#当能量小于20时，优先使用二技能回复能量以解锁一技能
	if curr_energy < 20:
		ai.skills[2].strategy_value_count = ai.skills[1].recover_shield*0.8

func add_shield(count,source:character_base = self):
	super.add_shield(count,source)
	taunt_value = 1+(shield/3200.0)
	
func be_damage(damage,source,damage_type:String,damage_element:String,is_extra:bool = false,energy = int(round(damage/100.0))):
	super.be_damage(damage,source,damage_type,damage_element,is_extra,energy)
	taunt_value = 1+(shield/3200.0)
