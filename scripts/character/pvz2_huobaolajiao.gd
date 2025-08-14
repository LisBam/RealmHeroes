extends character_base

func _ready() -> void:
	super._ready()
	tags.append("非人生物")
	skilla_description = "迸发烈焰灼烧敌人，造成1000威力的火属性法伤。"
	skillb_description = "进行光合作用，立即恢复10点能量，并回复100点HP。"
	skillc_description = "迸发十字烈焰，提高30点法强（至多叠加三层），造成400威力的火属性法伤。"
	skilld_description = "燃爆自身与敌人同归于尽，自身HP降为0，对敌人造成3000威力的火属性法伤。"
	skilla_short_desc = "法伤"
	skillb_short_desc = "回能回血"
	skillc_short_desc = "+法强 法伤"
	skilld_short_desc = "自爆 法伤"

func skilla(enemy,player,enemy_team,player_team):
	await super.skilla(enemy,player,enemy_team,player_team)
	be_and_to_damage(damage(1000,"mag",enemy,skilla_element),enemy,player,"mag",skilla_element)
	attack_skill_animation()
	Signals.to_next_phase.emit()

func skillb(enemy,player,enemy_team,player_team):
	super.skillb(enemy,player,enemy_team,player_team)
	recover_energy(10)
	recover(100)
	tool_skill_animation()
	Signals.to_next_phase.emit()
	
func skillc(enemy,player,enemy_team,player_team):
	super.skillc(enemy,player,enemy_team,player_team)
	var add_power = huobaolajiao_add_power.new()
	add_power.round_duration = -1
	add_power.init_round_duration = -1
	player.get_node("buff").add_buff(add_power)
	be_and_to_damage(damage(400,"mag",enemy,skillc_element),enemy,player,"mag",skillc_element)
	attack_skill_animation()
	Signals.to_next_phase.emit()
	
func skilld(enemy,player,enemy_team,player_team):
	super.skilld(enemy,player,enemy_team,player_team)
	curr_hp = 0
	be_and_to_damage(damage(3000,"mag",enemy,skillc_element),enemy,player,"phy",skillc_element)
	attack_skill_animation()
	Signals.to_next_phase.emit()

func refresh_ai(enemy,player,enemy_team,player_team):
	await super.refresh_ai(enemy,player,enemy_team,player_team)
	
	add_damage_element(0,skilla_element)
	ai.skills[1].damage_count = 1000
	
	ai.skills[2].recover_hp = 100
	ai.skills[2].recover_energy = 10
	
	
	add_damage_element(3,skillc_element)
	ai.skills[3].damage_count = 400
	ai.skills[3].buff_value = 30 * 15
	ai.skills[3].buff_duration = 5
	var stacks = get_node("buff").get_buff_stacks("huobaolajiao_add_power")
	if stacks >= 3:
		ai.skills[3].buff_value = 0
		ai.skills[3].buff_duration = 1
	#血量高时优先加强，血量低时权重下降
	#ai.skills[2].strategy_value_mul = 3-(max_hp/curr_hp)
	
	add_damage_element(4,skilld_element)
	ai.skills[4].to_die_value = 0.05 + (max_hp-curr_hp)/60000
	ai.skills[4].damage_count = 4000
	if curr_hp <= enemy.ai.get_enable_max_damage() * 2 or curr_hp <= 2000:
		ai.skills[4].strategy_value_count = 2000
	if curr_hp <= enemy.ai.get_enable_max_damage() or curr_hp <= 1000:
		ai.skills[4].strategy_value_count = 4000

	#血量低且能量低时优先屯够40能量释放四技能
	if (curr_hp <= enemy.ai.get_enable_max_damage() * 2 or curr_hp <=4000) and curr_energy < 50:
		ai.skills[1].strategy_value_mul = 1.2
		ai.skills[2].strategy_value_mul = 3
		ai.skills[4].strategy_value_mul = 1.5
