extends character_base

func _ready() -> void:
	super._ready()
	tags.append("植物")
	skilla_description = "点燃穿过的子弹，使其威力提升。选择一名友方角色，其下4次造成物理伤害都会附加火属性法伤，威力等同于你的五倍法强。释放此技能后不会结束回合。"
	skillb_description = "进行光合作用，立即恢复20点能量，并回复100点HP。"
	skillc_description = "火炬树桩以炽热的火焰灼伤靠近的敌人，对目标造成300威力的火属性物伤，并有40%概率令目标陷入灼烧持续4回合。"
	skilld_description = "驻守前线，助攻友方。令一名场下的友方角色立即上阵，然后你与其提高20点物抗持续4回合。"
	skilla_short_desc = "附加伤害"
	skillb_short_desc = "回能回血"
	skillc_short_desc = "物伤 灼烧"
	skilld_short_desc = "切换角色 提高物抗"

func skilla(enemy,player,enemy_team,player_team):
	super.skilla(enemy,player,enemy_team,player_team)
	add_shield(800)
	tool_skill_animation()
	Signals.to_next_phase.emit()

func skillb(enemy,player,enemy_team,player_team):
	super.skillb(enemy,player,enemy_team,player_team)
	recover_energy(20)
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
	be_and_to_damage(damage(350,"phy",enemy,"fire"),enemy,player,"phy","fire")
	be_and_to_damage(damage(350,"phy",enemy,"metal"),enemy,player,"phy","metal")
	be_and_to_damage(damage(350,"phy",enemy,"water"),enemy,player,"phy","water")
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
	ai.skills[4].damage_count = 350*3
	
	#当能量小于20时，优先使用二技能回复能量以解锁一技能
	if curr_energy < 20:
		ai.skills[2].strategy_value_count = ai.skills[1].recover_shield*0.8

func add_shield(count,source:character_base = self):
	super.add_shield(count,source)
	taunt_value = 1+(shield/3200.0)
	
func be_damage(damage,source,damage_type:String,damage_element:String,is_extra:bool = false,energy = int(round(damage/100.0))):
	super.be_damage(damage,source,damage_type,damage_element,is_extra,energy)
	taunt_value = 1+(shield/3200.0)
