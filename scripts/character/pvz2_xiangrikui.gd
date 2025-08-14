extends character_base

func _ready() -> void:
	super._ready()
	skilla_description = "产生阳光，回复800点HP，并回复10点能量。"
	skillb_description = "进行光合作用，立即恢复10点能量，并回复100点HP。"
	skillc_description = "落下一颗葵花籽，对站场的敌方造成400威力的木属性法伤，对场下的所有敌方造成100威力的木属性法伤。"
	skilld_description = "令下次上阵的其他友方角色于上阵时回复50点能量，然后向日葵失去所有HP。"
	skilla_short_desc = "回血回能"
	skillb_short_desc = "回能回血"
	skillc_short_desc = "群体法伤"
	skilld_short_desc = "自杀并为队友回能"

func skilla(enemy,player,enemy_team,player_team):
	super.skilla(enemy,player,enemy_team,player_team)
	recover(800)
	recover_energy(10)
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
	be_and_to_damage(damage(400,"mag",enemy,skillc_element),enemy,player,"mag",skillc_element)
	for character in enemy_team:
		if character and not character.is_die and character != enemy:
			be_and_to_damage(damage(100,"mag",character,skillc_element),character,player,"mag",skillc_element)
	attack_skill_animation()
	Signals.to_next_phase.emit()
	
#旧写法，选择buff目标再死亡。导致死亡后会再次选择切换角色目标，目标不一致。
#func skilld(enemy,player,enemy_team,player_team):
	#super.skilld(enemy,player,enemy_team,player_team)
	#var choice = await get_parent().choose_team_character(self,false,false)
	#curr_hp = 0
	#var recover_energy = xiangrikui_recover_energy_buff.new()
	#recover_energy.recover_energy_count = 50
	#if choice:
		#choice.get_node("buff").add_buff(recover_energy)
	#Signals.to_next_phase.emit()
	
func skilld(enemy,player,enemy_team,player_team):
	super.skilld(enemy,player,enemy_team,player_team)
	curr_hp = 0
	for character in player_team:
		var recover_energy = xiangrikui_recover_energy_buff.new()
		recover_energy.recover_energy_count = 50
		recover_energy.round_duration = -1
		if character != self and character and not character.is_die:
			character.get_node("buff").add_buff(recover_energy)
	Signals.to_next_phase.emit()

func refresh_ai(enemy,player,enemy_team,player_team):
	await super.refresh_ai(enemy,player,enemy_team,player_team)
	
	ai.skills[1].recover_hp = 800
	ai.skills[1].recover_energy = 10
	
	ai.skills[2].recover_hp = 100
	ai.skills[2].recover_energy = 10
	
	add_damage_element(3,skillc_element)
	#ai.skills[3].damage_count = 200
	ai.skills[3].damage_aoe_count = 100 * enemy_team.size()-1
	ai.skills[3].damage_aoe_justone_count = 400
	
	#死亡价值0.2
	ai.skills[4].to_die_value = 0.4
	#血量低时提高战略价值
	if curr_hp <= enemy.ai.get_enable_max_damage() * 2 or curr_hp <= 2000:
		ai.skills[4].strategy_value_count = 1500
	if curr_hp <= enemy.ai.get_enable_max_damage() or curr_hp <= 1000:
		ai.skills[4].strategy_value_count = 3000
	if is_ai:
		if enemy_team.size() <= 1:
			ai.skills[4].strategy_value_count = 0
	#buff价值
	ai.skills[4].buff_value = 50 * ai.ENERGY_VALUE
	
	#血量低且能量低时优先屯够30能量释放四技能
	if (curr_hp <= enemy.ai.get_enable_max_damage() * 2 or curr_hp <4000) and curr_energy < 40:
		ai.skills[2].strategy_value_mul = 2
		ai.skills[4].strategy_value_mul = 3
	else:
		ai.skills[2].strategy_value_mul = 1
		ai.skills[4].strategy_value_mul = 1
