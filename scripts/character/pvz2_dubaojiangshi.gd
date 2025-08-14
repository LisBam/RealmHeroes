extends character_base

func _ready() -> void:
	super._ready()
	tags.append("亡灵生物")
	skilla_description = "啃食敌人对其造成伤害，造成1000威力的土属性物伤。"
	skillb_description = "它不是一个人！队伍里每有一只亡灵生物，都会提供持续3轮的20点物攻。该效果不可叠加。"
	skillc_description = "知识就是力量。释放技能后的4轮内，每次造成物理伤害都会附加一段600威力的土属性法伤。该效果不可叠加。"
	skilld_description = "失去报纸进入暴走。立即消耗所有能量，每以此法失去10点能量，便对敌方造成一段50威力的火属性物伤。"
	skilla_short_desc = "物伤"
	skillb_short_desc = "根据亡灵生物数提升物攻"
	skillc_short_desc = "附加伤害"
	skilld_short_desc = "清空能量 爆发"

func skilla(enemy,player,enemy_team,player_team):
	super.skilla(enemy,player,enemy_team,player_team)
	be_and_to_damage(damage(1000,"phy",enemy,skilla_element),enemy,player,"phy",skilla_element)
	attack_skill_animation()
	Signals.to_next_phase.emit()

func skillb(enemy,player,enemy_team,player_team):
	super.skillb(enemy,player,enemy_team,player_team)
	var putongjiangshi_phy_power = putongjiangshi_phy_power.new()
	putongjiangshi_phy_power.add_count = 0
	putongjiangshi_phy_power.round_duration = 3
	putongjiangshi_phy_power.init_round_duration = 3
	for character in player_team:
		if character and character.has_tag("亡灵生物"):
			putongjiangshi_phy_power.add_count += 20
	player.get_node("buff").add_buff(putongjiangshi_phy_power)
	tool_skill_animation()
	Signals.to_next_phase.emit()
	
func skillc(enemy,player,enemy_team,player_team):
	super.skillc(enemy,player,enemy_team,player_team)
	var extra_mag_damage = dubaojiangshi_extra_mag_damage.new()
	extra_mag_damage.round_duration = 4
	extra_mag_damage.init_round_duration = 4
	#获得buff的同时会增加读报僵尸的卖血倍率
	player.get_node("buff").add_buff(extra_mag_damage)
	tool_skill_animation()
	Signals.to_next_phase.emit()
	
func skilld(enemy,player,enemy_team,player_team):
	super.skilld(enemy,player,enemy_team,player_team)
	var lost_energy = curr_energy
	var damage_times = lost_energy/10
	remove_energy(lost_energy)
	for i in range(damage_times):
		be_and_to_damage(damage(50,"phy",enemy,skilld_element),enemy,player,"phy",skilld_element)
	attack_skill_animation()
	Signals.to_next_phase.emit()

func to_damage(damage,target,damage_type:String,damage_element:String,is_extra:bool = false,energy = 0):
	super.to_damage(damage,target,damage_type,damage_element,is_extra,energy)
	if damage_type == "phy" and not is_extra and get_node("buff").has_buff("dubaojiangshi_extra_mag_damage"):
		be_and_to_damage(damage(600,"mag",target,skillc_element),target,self,"mag",skillc_element,true)

func refresh_ai(enemy,player,enemy_team,player_team):
	await super.refresh_ai(enemy,player,enemy_team,player_team)
	
	var skillc_extra_damage = 600
	add_damage_element(0,skilla_element)
	ai.skills[0].damage_count = 1000
	if get_node("buff").has_buff("putongjiangshi_phy_power"):
		ai.skills[0].damage_count+=skillc_extra_damage
	
	ai.skills[1].buff_value = 0
	for character in player_team:
		if character and character.has_tag("亡灵生物"):
			ai.skills[1].buff_value += 20 * 10 #每点物攻对一技能来说大概造成10点伤害
	ai.skills[1].buff_duration = 4-1
	if get_node("buff").has_buff("putongjiangshi_phy_power"):
		ai.skills[1].buff_value = 0

	if not get_node("buff").has_buff("dubaojiangshi_extra_mag_damage"):
		ai.skills[2].buff_value = skillc_extra_damage * magical_power/100 #乘以法强价值
		ai.skills[2].buff_duration = 4-1
	else:
		ai.skills[2].buff_value = 0
		ai.skills[2].buff_duration = 0
	
	add_damage_element(3,skilld_element)
	add_damage_element(3,"earth")
	add_damage_type(3,"mag")
	#能量成本重置为全部能量
	ai.skills[3].energy_cost = curr_energy
	var lost_energy = curr_energy
	var damage_times = lost_energy/10
	ai.skills[3].damage_count = 50 * damage_times
	if get_node("buff").has_buff("dubaojiangshi_extra_mag_damage"):
		ai.skills[3].damage_count = 50 + skillc_extra_damage * damage_times
	
	#该角色耗蓝量大，能量少时限制技能
	ai.skills[1].strategy_value_mul = 0.5 + float(curr_energy)/max_energy
	ai.skills[2].strategy_value_mul = 0.5 + float(curr_energy)/max_energy
