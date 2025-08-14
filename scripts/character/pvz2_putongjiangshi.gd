extends character_base

func _ready() -> void:
	super._ready()
	tags.append("亡灵生物")
	skilla_description = "啃食敌人对其造成伤害，造成1000威力的土属性物伤。"
	skillb_description = "它不是一个人！队伍里每有一只亡灵生物，都会提供持续3轮的20点物攻。该效果不可叠加。"
	skillc_description = "迈向植物，发起进攻。提高10点速度持续2轮，重复释放可延长持续时间。释放后不会结束回合。"
	skilld_description = "濒死的身躯屹立不倒，为队友拦截火力。释放后于2轮内受到下一次致命伤害会保留1点HP，连续释放会失效。"
	skilla_short_desc = "物伤"
	skillb_short_desc = "根据亡灵生物数提升物攻"
	skillc_short_desc = "加速 连续回合"
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
	var add_speed = putongjiangshi_add_speed.new()
	add_speed.add_count = 10
	add_speed.round_duration = 2
	add_speed.init_round_duration = 2
	player.get_node("buff").add_buff(add_speed)
	tool_skill_animation()
	if is_ai:
		await get_tree().create_timer(0.1).timeout
		get_parent().ai_continue_action = true
		Signals.to_next_phase.emit()
	
func skilld(enemy,player,enemy_team,player_team):
	super.skilld(enemy,player,enemy_team,player_team)
	var not_die = putongjiangshi_not_die.new()
	not_die.add_count = 1
	not_die.round_duration = 2
	not_die.init_round_duration = 2
	player.get_node("buff").add_buff(not_die)
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

	#发动后若速度能够反超或持平则释放
	if speed < enemy.speed and speed+10 >= enemy.speed:
		#反超价值更高
		if speed+10 > enemy.speed:
			ai.skills[3].buff_value = 600
		if speed+10 == enemy.speed:
			ai.skills[3].buff_value = 300
		if speed+10 < enemy.speed:
			ai.skills[3].buff_value = 80
		ai.skills[3].buff_duration = 3
		ai.skills[3].can_continue = true
		#能量充足时提高发动价值,反之减少
		ai.skills[3].strategy_value_mul = 0.5 + curr_energy/max_energy
	#满能量不用白不用
	if curr_energy == max_energy:
		ai.skills[3].strategy_value_count = 2000
	
	#血量足够被击杀时释放名刀
	if enemy.ai.get_enable_max_damage(10) > curr_hp:
		if not_die_to_one_hp <= 0 and not get_node("buff").has_buff("putongjiangshi_not_die"):
			ai.skills[4].buff_value = 1000
			ai.skills[4].buff_duration = 2
		else:
			ai.skills[4].buff_value = 0
			ai.skills[4].buff_duration = 0
