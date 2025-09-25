extends character_base

func _ready() -> void:
	super._ready()
	skilla_description = "帕尔萨斯安定神思，造成600威力的土属性法伤，并有20%的概率提高20点物攻、法强、物抗、法抗以及速度（至多叠加6层）。"
	skillb_description = "巨魔之眼凝视敌人，若你的法强低于对方，则有60%概率交换你与对方的法强。若你的血量低于对方，则有40%概率交换你与对方的血量。一次技能只能生效其中一项。"
	skillc_description = "释放幽冥火灼烧敌方，造成固定的800点火属性真伤。每点法强与物攻均会使此伤害+1。"
	skilld_description = "展开恶魔虹吸汲取生命，有40%概率使对方的血量减半。当你的物攻或法强高于100点时，每额外多出1点便会使此概率+1%。"
	skilla_short_desc = "法伤 强化五维"
	skillb_short_desc = "交换血量或法强"
	skillc_short_desc = "固定法伤"
	skilld_short_desc = "血量减半"

func skilla(enemy,player,enemy_team,player_team):
	super.skilla(enemy,player,enemy_team,player_team)
	be_and_to_damage(damage(600,"mag",enemy,skilla_element),enemy,player,"mag",skilla_element)
	var buff_probability = 20;
	var random = randi_range(1,100);
	if random <= buff_probability:
		var add_buff = add_all_stats.new()
		add_buff.add_count = 20
		add_buff.max_stacks = 6
		add_buff.round_duration = -1
		add_buff.init_round_duration = -1
		player.get_node("buff").add_buff(add_buff)
	attack_skill_animation()
	Signals.to_next_phase.emit()

func skillb(enemy,player,enemy_team,player_team):
	super.skillb(enemy,player,enemy_team,player_team)
	var have_change:bool = false
	if magical_power < enemy.magical_power:
		var probability = 60;
		var random = randi_range(1,100);
		if random <= probability:
			var temp = magical_power;
			magical_power = enemy.magical_power;
			enemy.magical_power = temp;
			have_change = true;
			addlog("双方的魔攻被交换了！",true);
	if curr_hp < enemy.curr_hp and not have_change:
		var probability = 40;
		var random = randi_range(1,100);
		if random <= probability:
			var temp = curr_hp;
			curr_hp = enemy.curr_hp;
			enemy.curr_hp = temp;
			have_change = true;
			addlog("双方的血量被交换了！",true);
	tool_skill_animation()
	Signals.to_next_phase.emit()
	
func skillc(enemy,player,enemy_team,player_team):
	super.skillc(enemy,player,enemy_team,player_team);
	var real_damage = 800 + physical_power + magical_power;
	be_and_to_damage(real_damage,enemy,player,"real",skillc_element);
	attack_skill_animation();
	Signals.to_next_phase.emit();
	
func skilld(enemy,player,enemy_team,player_team):
	super.skilld(enemy,player,enemy_team,player_team)
	var probability = 40;
	if physical_power>100:probability+=(physical_power-100);
	if magical_power>100:probability+=(magical_power-100);
	var random = randi_range(1,100);
	if random <= probability:
		enemy.curr_hp = int(enemy.curr_hp*0.5);
		addlog(enemy.character_name+"的血量减半了！");
	tool_skill_animation()
	Signals.to_next_phase.emit()

#func ai_action(enemy,player,enemy_team,player_team):
	#print("ai行动")
	#skilla(enemy,player,enemy_team,player_team)

func refresh_ai(enemy,player,enemy_team,player_team):
	await super.refresh_ai(enemy,player,enemy_team,player_team)
	
	add_damage_element(1,skilla_element)
	ai.skills[1].damage_count = 600
	ai.skills[2].buff_duration = 6
	
	#物抗收益
	var physical_defense_value = 10*(enemy.damage_phy_ratio/100);
	
	ai.skills[2].buff_value = 20 * 10 + 20*physical_defense_value;
	ai.skills[2].buff_duration = 7
	var stacks = get_node("buff").get_buff_stacks("caiwen_add_buff")
	if stacks >= 6:
		ai.skills[2].buff_value = 0
		ai.skills[2].buff_duration = 1
	
	add_damage_element(3,skillc_element)
	var stun_probability = 15;
	var skillc_damage = 500;
	if enemy.curr_hp < (enemy.max_hp - enemy.curr_hp):
		stun_probability = 30;
		skillc_damage = 1000;
	ai.skills[3].skip_enemy_phase_count = 1*(float(stun_probability)/100)
	ai.skills[3].damage_count = skillc_damage
	
	add_damage_element(4,skillc_element)
	ai.skills[4].damage_aoe_count = 150 * enemy_team.size()-1
	ai.skills[4].damage_aoe_justone_count = 1250
