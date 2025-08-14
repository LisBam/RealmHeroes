extends character_base

func _ready() -> void:
	super._ready()
	tags.append("亡灵生物")
	skilla_description = "啃食敌人对其造成伤害，造成1000威力的水属性物伤。"
	skillb_description = "它不是一个人！队伍里每有一只亡灵生物，都会提供持续3轮的20点物攻。该效果不可叠加。"
	skillc_description = "潜入水中，发起突袭。获得80%的免伤持续2轮，获得150%的增伤持续4轮，并跳过下一个回合。这些效果不可叠加。"
	skilld_description = "暗流般无声无息地接近敌人。释放后的6轮内，每轮开始时，浮潜僵尸对目标造成400威力的水属性物伤。该效果不可叠加。"
	skilla_short_desc = "物伤"
	skillb_short_desc = "根据亡灵生物数提升物攻"
	skillc_short_desc = "跳过回合 免伤 增伤"
	skilld_short_desc = "抵挡致命伤害"

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
	var damage_reduction = qianfujiangshi_damage_reduction.new()
	damage_reduction.add_count = 80
	damage_reduction.round_duration = 2
	damage_reduction.init_round_duration = 2
	player.get_node("buff").add_buff(damage_reduction)
	var damage_improve = qianfujiangshi_damage_improve.new()
	damage_improve.add_count = 150
	damage_improve.round_duration = 4
	damage_improve.init_round_duration = 4
	player.get_node("buff").add_buff(damage_improve)
	player.skip_next_phase = true
	tool_skill_animation()
	Signals.to_next_phase.emit()
	
func skilld(enemy,player,enemy_team,player_team):
	super.skilld(enemy,player,enemy_team,player_team)
	var mark = qianfujiangshi_skilld_mark.new()
	mark.damage = 400
	mark.round_duration = 6
	mark.init_round_duration = 6
	mark.source = player
	enemy.get_node("buff").add_buff(mark)
	tool_skill_animation()
	Signals.to_next_phase.emit()

#func ai_action(enemy,player,enemy_team,player_team):
	#print("ai行动")
	#skilla(enemy,player,enemy_team,player_team)

func refresh_ai(enemy,player,enemy_team,player_team):
	await super.refresh_ai(enemy,player,enemy_team,player_team)
	
	add_damage_element(1,skilla_element)
	ai.skills[1].damage_count = 1000
	
	ai.skills[2].buff_value = 0
	for character in player_team:
		if character and character.has_tag("亡灵生物"):
			ai.skills[2].buff_value += 20 * 10 #每点物攻对一技能来说大概造成10点伤害
	ai.skills[2].buff_duration = 3-1
	if get_node("buff").has_buff("putongjiangshi_phy_power"):
		ai.skills[2].buff_value = 0

	ai.skills[3].skip_phase_count = 1
	if not get_node("buff").has_buff("qianfujiangshi_damage_improve"):
		ai.skills[3].buff_value = 30 + ai.skills[1].value*1.5 #对普攻的增伤收益 + 增伤收益为令其他技能增加的伤害值
		ai.skills[3].buff_duration = 4-1-1 #跳过一回合+释放技能一回合不算
		ai.skills[3].damage_reduction = 80
		ai.skills[3].damage_reduction_round_duration = 2 #若速度慢则ai计算时会自动-1
	else:
		ai.skills[3].buff_value = 0
		ai.skills[3].buff_duration = 0
		ai.skills[3].damage_reduction = 0
		ai.skills[3].damage_reduction_round_duration = 0

	
	#血量足够被击杀时释放名刀
	if enemy.ai.get_enable_max_damage(10) > curr_hp:
		if not_die_to_one_hp <= 0 and not get_node("buff").has_buff("putongjiangshi_not_die"):
			ai.skills[3].buff_value = 1000
			ai.skills[3].buff_duration = 2
		else:
			ai.skills[3].buff_value = 0
			ai.skills[3].buff_duration = 0
