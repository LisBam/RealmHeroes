extends character_base

func _ready() -> void:
	super._ready()
	tags.append("植物")
	skilla_description = "点燃穿过的子弹，使其威力提升。选择一名友方角色，其下5次造成物理伤害都会附加火属性法伤，威力等同于你的五倍法强。释放此技能后不会结束回合。"
	skillb_description = "进行光合作用，立即恢复20点能量，并回复100点HP。"
	skillc_description = "火炬树桩以炽热的火焰灼伤靠近的敌人，对目标造成800威力的火属性物伤，并有40%概率令目标陷入灼烧持续2回合。"
	skilld_description = "驻守前线，助攻友方。令一名场下的友方角色立即上阵，然后你与其提高30点物抗持续4轮。"
	skilla_short_desc = "附加伤害"
	skillb_short_desc = "回能回血"
	skillc_short_desc = "物伤 灼烧"
	skilld_short_desc = "切换角色 提高物抗"

func skilla(enemy,player,enemy_team,player_team):
	super.skilla(enemy,player,enemy_team,player_team)
	var choice = await get_parent().choose_team_character(self,true,true,false,"highest_physical_ratio");
	#防止重复给一名角色上buff
	if is_ai and choice.get_node("buff").has_buff("huojvshuzhuang_skilla_mark"):
		choice = self;
	var mark = huojvshuzhuang_skilla_mark.new();
	mark.count = 5;
	mark.round_duration = -1;
	mark.source = self;
	mark.target = choice;
	choice.get_node("buff").add_buff(mark);
	addlog("选择了"+choice.character_name)
	tool_skill_animation()
	if is_ai:
		await get_tree().create_timer(0.1).timeout
		get_parent().ai_continue_action = true
		Signals.to_next_phase.emit()

func skillb(enemy,player,enemy_team,player_team):
	super.skillb(enemy,player,enemy_team,player_team)
	recover_energy(20)
	recover(100)
	tool_skill_animation()
	Signals.to_next_phase.emit()
	
func skillc(enemy,player,enemy_team,player_team):
	super.skillc(enemy,player,enemy_team,player_team)
	be_and_to_damage(damage(800,"phy",enemy,skillc_element),enemy,player,"phy",skillc_element)
	var burn_probability = 40;
	var random = randi_range(1,100);
	if random <= burn_probability:
		enemy.burn(2,self)
	attack_skill_animation()
	Signals.to_next_phase.emit()
	
func skilld(enemy,player,enemy_team,player_team):
	super.skilld(enemy,player,enemy_team,player_team)
	var choice = await get_parent().choose_team_character(self,true,true,false,"highest_physical_ratio");
	get_parent().change_character_to(choice);
	var add = quanmingxingjiangshi_add_phy_def.new()
	add.count = 30
	add.round_duration = 4
	add.init_round_duration = 4
	add.source = self;
	add.target = player;
	player.get_node("buff").add_buff(add)
	add.target = choice;
	choice.get_node("buff").add_buff(add)
	tool_skill_animation()
	Signals.to_next_phase.emit()

func refresh_ai(enemy,player,enemy_team,player_team):
	await super.refresh_ai(enemy,player,enemy_team,player_team)
	
	ai.skills[1].strategy_value_count = 5*(get_magical_power()*5)
	ai.skills[1].can_continue = true
	
	ai.skills[2].recover_hp = 100
	ai.skills[2].recover_energy = 20
	
	add_damage_element(3,skillc_element)
	ai.skills[3].damage_count = 800
	ai.skills[3].burning_phase = (2-enemy.burning_phase)*0.4;
	
	#根据对方物伤占比提供收益,2为两人
	if not get_node("buff").has_buff("quanmingxingjiangshi_add_phy_def"):
		ai.skills[3].buff_value = 30*8*4*(enemy.damage_phy_ratio/80.0)*2
	else:
		ai.skills[3].buff_value = 0
	#先手多生效一回合
	if Global.curr_phase_count % 2 != 0:
		ai.skills[3].buff_duration = 3
	else:
		ai.skills[3].buff_duration = 3-1
	ai.skills[4].strategy_value_count = ai.change_character_value()
