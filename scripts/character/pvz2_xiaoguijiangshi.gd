extends character_base

func _ready() -> void:
	super._ready()
	tags.append("亡灵生物")
	skilla_description = "啃食敌人对其造成伤害，造成1000威力的土属性物伤。"
	skillb_description = "它不是一个人！队伍里每有一只亡灵生物，都会提供持续3轮的20点物攻。该效果不可叠加。"
	skillc_description = "从天而降，深入敌阵。每当你登场时，若能量足够，则自动释放一次此技能。对敌方造成1200威力的土属性物伤。"
	skilld_description = "小巧灵活，游走战场。回复800点生命值并立即切换一次角色。"
	skilla_short_desc = "物伤"
	skillb_short_desc = "根据亡灵生物数提升物攻"
	skillc_short_desc = "登场释放 物伤"
	skilld_short_desc = "回血 切换角色"

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
	
func skillc(enemy,player,enemy_team,player_team,is_enter_skill:bool = false):
	super.skillc(enemy,player,enemy_team,player_team)
	be_and_to_damage(damage(1200,"phy",enemy,skilla_element),enemy,player,"phy",skilla_element)
	attack_skill_animation()
	if not is_enter_skill:
		Signals.to_next_phase.emit()
	
func skilld(enemy,player,enemy_team,player_team):
	super.skilld(enemy,player,enemy_team,player_team)
	recover(800)
	tool_skill_animation()
	var choice = await get_parent().choose_team_character(self,true,false);
	get_parent().change_character_to(choice);
	Signals.to_next_phase.emit()

func enter_skill(enemy,player,enemy_team,player_team):
	await get_tree().create_timer(0.5).timeout
	if curr_energy>=skillc_energy:
		skillc(enemy,player,enemy_team,player_team,true);

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

	add_damage_element(3,skillc_element)
	ai.skills[3].damage_count = 1200
	
	ai.skills[4].recover_hp = 800
	ai.skills[4].strategy_value_count = ai.change_character_value()
