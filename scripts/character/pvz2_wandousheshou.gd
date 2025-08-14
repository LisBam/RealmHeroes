extends character_base

func _ready() -> void:
	super._ready()
	skilla_description = "发射豌豆攻击对方，造成1000威力的木属性物伤。"
	skillb_description = "进行光合作用，立即恢复10点能量，并回复100点HP。"
	skillc_description = "发射豌豆攻击对方，造成400威力的木属性物伤。发动后不结束回合。"
	skilld_description = "发射威力巨大的超级豌豆，造成4000威力的木属性物伤。"
	skilla_short_desc = "物伤"
	skillb_short_desc = "回能回血"
	skillc_short_desc = "物伤 连续回合"
	skilld_short_desc = "物伤"

func skilla(enemy,player,enemy_team,player_team):
	super.skilla(enemy,player,enemy_team,player_team)
	be_and_to_damage(damage(1000,"phy",enemy,skilla_element),enemy,player,"phy",skilla_element)
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
	be_and_to_damage(damage(400,"phy",enemy,skillc_element),enemy,player,"phy",skillc_element)
	attack_skill_animation()
	if is_ai:
		get_parent().ai_continue_action = true
		Signals.to_next_phase.emit()
	
func skilld(enemy,player,enemy_team,player_team):
	super.skilld(enemy,player,enemy_team,player_team)
	be_and_to_damage(damage(4000,"phy",enemy,skillc_element),enemy,player,"phy",skillc_element)
	attack_skill_animation()
	Signals.to_next_phase.emit()

#func ai_action(enemy,player,enemy_team,player_team):
	#print("ai行动")
	#skilla(enemy,player,enemy_team,player_team)

func refresh_ai(enemy,player,enemy_team,player_team):
	await super.refresh_ai(enemy,player,enemy_team,player_team)
	
	add_damage_element(0,skilla_element)
	ai.skills[0].damage_count = 1000
	
	ai.skills[1].recover_hp = 100
	ai.skills[1].recover_energy = 10
	
	add_damage_element(2,skillc_element)
	ai.skills[2].damage_count = 400
	ai.skills[2].can_continue = true
	
	add_damage_element(3,skilld_element)
	ai.skills[3].damage_count = 4000
