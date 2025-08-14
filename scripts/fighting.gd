extends Node

@export var ai_think_time = 0.5 ##ai思考时长
@export var animation_wait_time = 1.2 ##动画开始播放后多少时间可以操作

@export var log:RichTextLabel

var player_character_1_scene:PackedScene
var player_character_2_scene:PackedScene
var player_character_3_scene:PackedScene
var player_character_4_scene:PackedScene

var enemy_character_1_scene:PackedScene
var enemy_character_2_scene:PackedScene
var enemy_character_3_scene:PackedScene
var enemy_character_4_scene:PackedScene

var player_character_1
var player_character_2
var player_character_3
var player_character_4
var player_character_curr
var enemy_character_1
var enemy_character_2
var enemy_character_3
var enemy_character_4
var enemy_character_curr

#队伍存活角色数
var player_team_alive:int = 0
var enemy_team_alive:int = 0

#ai继续回合。在不结束回合的技能发动后应调整值为true，否则会导致ai不再行动
var ai_continue_action :bool = false

#是否有某个人死亡，用于阻断下个回合函数的运行，避免敌方在我方切换角色期间对已死亡角色持续造成伤害
@export var someone_is_die:int = 0

#跳过敌方下个回合，用于敌方死亡后跳过一回合
var skip_enemy_next_phase:bool = false

#确认初始化的节点位置大小
@onready var player_scale = $UI/Control/player_sprite.scale
@onready var player_position = $UI/Control/player_sprite.position
@onready var enemy_scale = $UI/Control/enemy_sprite.scale
@onready var enemy_position = $UI/Control/enemy_sprite.position

#缓存血条与能量条与护盾，减少每帧检索路径的开销
@onready var player_hp_bar := $UI/Control/player1_stat/HpBar
@onready var enemy_hp_bar := $UI/Control/player2_stat/HpBar
@onready var player_energy_bar := $UI/Control/player1_stat/EnergyBar
@onready var enemy_energy_bar := $UI/Control/player2_stat/EnergyBar
@onready var player_shield := $UI/Control/player1_stat/HpBar/Shield_Label
@onready var enemy_shield := $UI/Control/player2_stat/HpBar/Shield_Label

# 角色列表（用于索引管理）
var player_team: Array = []
var enemy_team: Array = []

#region回合机制
var curr_phase: String
#endregion

func _ready() -> void:
	#战斗的预备角色scene
	player_character_1_scene = Global.team_character_1_scene
	player_character_2_scene = Global.team_character_2_scene
	player_character_3_scene = Global.team_character_3_scene
	player_character_4_scene = Global.team_character_4_scene
	#战斗的预备敌人scene
	enemy_character_1_scene = Global.enemy_character_1_scene
	enemy_character_2_scene = Global.enemy_character_2_scene
	enemy_character_3_scene = Global.enemy_character_3_scene
	enemy_character_4_scene = Global.enemy_character_4_scene
	#初始化角色与敌人，并为敌人添加ai标签
	if player_character_1_scene:
		player_character_1 = player_character_1_scene.instantiate()
	if player_character_2_scene:
		player_character_2 = player_character_2_scene.instantiate()
	if player_character_3_scene:
		player_character_3 = player_character_3_scene.instantiate()
	if player_character_4_scene:
		player_character_4 = player_character_4_scene.instantiate()
	if enemy_character_1_scene:
		enemy_character_1 = enemy_character_1_scene.instantiate()
		enemy_character_1.is_ai = true
		print(enemy_character_1.character_name,"已被标记为ai")
	if enemy_character_2_scene:
		enemy_character_2 = enemy_character_2_scene.instantiate()
		enemy_character_2.is_ai = true
		print(enemy_character_2.character_name,"已被标记为ai")
	if enemy_character_3_scene:
		enemy_character_3 = enemy_character_3_scene.instantiate()
		enemy_character_3.is_ai = true
		print(enemy_character_3.character_name,"已被标记为ai")
	if enemy_character_4_scene:
		enemy_character_4 = enemy_character_4_scene.instantiate()
		enemy_character_4.is_ai = true
		print(enemy_character_4.character_name,"已被标记为ai")
	#加载所有角色与敌人
	add_child(player_character_1)
	add_child(player_character_2)
	add_child(player_character_3)
	add_child(player_character_4)
	add_child(enemy_character_1)
	add_child(enemy_character_2)
	add_child(enemy_character_3)
	add_child(enemy_character_4)
	# 初始化角色列表
	player_team = [player_character_1, player_character_2, player_character_3, player_character_4]
	enemy_team = [enemy_character_1, enemy_character_2, enemy_character_3, enemy_character_4]
	
	#初始化首发角色与敌人
	player_character_curr = player_team[0]
	enemy_character_curr = enemy_team[0]
	
	#初始化队伍里每个角色的名字
	if player_character_1:
		$UI/Control/button/change_character/character1/name.text = player_character_1.character_name
		$UI/Control/button/choose_player_character/character1/name.text = player_character_1.character_name
	else:
		$UI/Control/button/change_character/character1/name.text = "（空置）"
		$UI/Control/button/choose_player_character/character1/name.text = "（空置）"
	if player_character_2:
		$UI/Control/button/change_character/character2/name.text = player_character_2.character_name
		$UI/Control/button/choose_player_character/character2/name.text = player_character_2.character_name
	else:
		$UI/Control/button/change_character/character2/name.text = "（空置）"
		$UI/Control/button/choose_player_character/character2/name.text = "（空置）"
	if player_character_3:
		$UI/Control/button/change_character/character3/name.text = player_character_3.character_name
		$UI/Control/button/choose_player_character/character3/name.text = player_character_3.character_name
	else:
		$UI/Control/button/change_character/character3/name.text = "（空置）"
		$UI/Control/button/choose_player_character/character3/name.text = "（空置）"
	if player_character_4:
		$UI/Control/button/change_character/character4/name.text = player_character_4.character_name
		$UI/Control/button/choose_player_character/character4/name.text = player_character_4.character_name
	else:
		$UI/Control/button/change_character/character4/name.text = "（空置）"
		$UI/Control/button/choose_player_character/character4/name.text = "（空置）"
	
	#第一轮
	Global.curr_phase_count = 1
	Global.curr_round_count = 1
	#判断先后手
	speed_to_judge_phase()
	print("开局为",curr_phase,"的回合")
	
	#初始化存活角色数
	for character in player_team:
		if character and character.curr_hp > 0:
			player_team_alive+=1
	for character in enemy_team:
		if character and character.curr_hp > 0:
			enemy_team_alive+=1
	print("玩家队伍人数：",player_team_alive)
	print("敌方队伍人数：",enemy_team_alive)
	
	#初始化函数
	refresh_curr_character()
	refresh_team_stat()
	refresh_stat_ui()
	refresh_skill_button()
	init_position_and_scale()
	refresh_skill_description()
	refresh_ai()
	
	#按速度加载入场动画（影响入场技能）
	if player_character_curr.speed > enemy_character_curr.speed:
		active_enter_animation(player_character_curr)
		active_enter_animation(enemy_character_curr)
	elif player_character_curr.speed < enemy_character_curr.speed:
		active_enter_animation(player_character_curr)
		active_enter_animation(enemy_character_curr)
	elif player_character_curr.speed == enemy_character_curr.speed:
		var random = randi_range(0,1)
		if random == 0:
			active_enter_animation(player_character_curr)
			active_enter_animation(enemy_character_curr)
		else:
			active_enter_animation(enemy_character_curr)
			active_enter_animation(player_character_curr)
			
	#print开局信息展示
	print("我方角色：",player_character_curr.character_name,"|当前血量：",player_character_curr.curr_hp,"|当前能量：",player_character_curr.curr_energy)
	print("敌方角色：",enemy_character_curr.character_name,"|当前血量：",enemy_character_curr.curr_hp,"|当前能量：",enemy_character_curr.curr_energy)
	print("——————————————————————————————————————————————————")
	
	#连接信号
	Signals.to_next_phase.connect(to_next_phase)

func _physics_process(delta: float) -> void:
	#刷新ui
	refresh_phase_round_ui()
	#动画期间禁用按键
	if Global.playing_animation_time > 0:
		begin_animation()
	#持续刷新角色的生命值与能量值与护盾量
	player_hp_bar.max_value = player_character_curr.max_hp
	player_hp_bar.value = player_character_curr.curr_hp
	enemy_hp_bar.max_value = enemy_character_curr.max_hp
	enemy_hp_bar.value = enemy_character_curr.curr_hp
	player_energy_bar.max_value = player_character_curr.max_energy
	player_energy_bar.value = player_character_curr.curr_energy
	enemy_energy_bar.max_value = enemy_character_curr.max_energy
	enemy_energy_bar.value = enemy_character_curr.curr_energy
	#护盾量，为0时隐藏ui
	if player_character_curr.shield != 0:
		player_shield.text = str(player_character_curr.shield)
		if not player_shield.visible:
			player_shield.visible = true
	else:
		if player_shield.visible:
			player_shield.visible = false
	if enemy_character_curr.shield != 0:
		enemy_shield.text = str(enemy_character_curr.shield)
		if not enemy_shield.visible:
			enemy_shield.visible = true
	else:
		if enemy_shield.visible:
			enemy_shield.visible = false
	#刷新数值显示UI
	$UI/Control/player1_stat/HpBar/Label.text = str(player_character_curr.curr_hp) + "/" + str(player_character_curr.max_hp)
	$UI/Control/player2_stat/HpBar/Label.text = str(enemy_character_curr.curr_hp) + "/" + str(enemy_character_curr.max_hp)
	$UI/Control/player1_stat/EnergyBar/Label.text = str(player_character_curr.curr_energy) + "/" + str(player_character_curr.max_energy)
	$UI/Control/player2_stat/EnergyBar/Label.text = str(enemy_character_curr.curr_energy) + "/" + str(enemy_character_curr.max_energy)

	#判断角色死亡以及胜负
	judge_character_die()
	
	#刷新站场角色
	refresh_is_curr()
	
	#切换角色会导致其-1，因此需要限制
	someone_is_die = max(someone_is_die,0)
	
#刷新双方队伍存活状态UI
func refresh_team_stat():
	if player_character_1:
		$UI/Control/player1_stat/team_stat1.frame = 0
		if player_character_1.is_die:
			$UI/Control/player1_stat/team_stat1.frame = 1
	else:
		$UI/Control/player1_stat/team_stat1.frame = 2
	if player_character_2:
		$UI/Control/player1_stat/team_stat2.frame = 0
		if player_character_2.is_die:
			$UI/Control/player1_stat/team_stat2.frame = 1
	else:
		$UI/Control/player1_stat/team_stat2.frame = 2
	if player_character_3:
		$UI/Control/player1_stat/team_stat3.frame = 0
		if player_character_3.is_die:
			$UI/Control/player1_stat/team_stat3.frame = 1
	else:
		$UI/Control/player1_stat/team_stat3.frame = 2
	if player_character_4:
		$UI/Control/player1_stat/team_stat4.frame = 0
		if player_character_4.is_die:
			$UI/Control/player1_stat/team_stat4.frame = 1
	else:
		$UI/Control/player1_stat/team_stat4.frame = 2
	if enemy_character_1:
		$UI/Control/player2_stat/team_stat1.frame = 0
		if enemy_character_1.is_die:
			$UI/Control/player2_stat/team_stat1.frame = 1
	else:
		$UI/Control/player2_stat/team_stat1.frame = 2
	if enemy_character_2:
		$UI/Control/player2_stat/team_stat2.frame = 0
		if enemy_character_2.is_die:
			$UI/Control/player2_stat/team_stat2.frame = 1
	else:
		$UI/Control/player2_stat/team_stat2.frame = 2
	if enemy_character_3:
		$UI/Control/player2_stat/team_stat3.frame = 0
		if enemy_character_3.is_die:
			$UI/Control/player2_stat/team_stat3.frame = 1
	else:
		$UI/Control/player2_stat/team_stat3.frame = 2
	if enemy_character_4:
		$UI/Control/player2_stat/team_stat4.frame = 0
		if enemy_character_4.is_die:
			$UI/Control/player2_stat/team_stat4.frame = 1
	else:
		$UI/Control/player2_stat/team_stat4.frame = 2

#刷新站场角色贴图
func refresh_curr_character():
	#刷新贴图
	for character in player_team:
		if character:
			if character != player_character_curr:
				character.get_node("Sprite2D").visible = false
			else :
				character.get_node("Sprite2D").visible = true
	for character in enemy_team:
		if character:
			if character != enemy_character_curr:
				character.get_node("Sprite2D").visible = false
			else :
				character.get_node("Sprite2D").visible = true
				
func _skilla(audio:bool = true) -> void:
	if audio:
		$audio/button.play()
	player_character_curr.skilla(enemy_character_curr,player_character_curr,enemy_team,player_team)

func _skillb(audio:bool = true) -> void:
	if audio:
		$audio/button.play()
	player_character_curr.skillb(enemy_character_curr,player_character_curr,enemy_team,player_team)

func _skillc(audio:bool = true) -> void:
	if audio:
		$audio/button.play()
	player_character_curr.skillc(enemy_character_curr,player_character_curr,enemy_team,player_team)

func _skilld(audio:bool = true) -> void:
	if audio:
		$audio/button.play()
	player_character_curr.skilld(enemy_character_curr,player_character_curr,enemy_team,player_team)

#点击切换角色按钮
func _to_change_character(audio:bool = true) -> void:
	if audio:
		$audio/button.play()
	var change_to = await choose_team_character(player_character_curr,false,false)
	if change_to and not str(change_to) == "none":
		if player_character_curr != change_to:
			if not player_character_curr.dying:
				active_exit_animation(player_character_curr)
			player_character_curr = change_to
			disable_all_change_character_button()
			disable_all_extend_and_skill_buttons()
		addlog("玩家切换角色至 "+player_character_curr.character_name)
		print("玩家主动切换角色至"+player_character_curr.character_name+"，跳过一回合")
		active_enter_animation(player_character_curr)
		_to_fight(false)
		refresh_stat_ui()
		refresh_skill_button()
		to_next_phase()

#点击切换战斗按钮
func _to_fight(audio:bool = true) -> void:
	if audio:
		$audio/button.play()
	#重置为禁用切换战斗按钮
	$UI/Control/button/extend/fight.disabled = true
	$UI/Control/button/extend/character.disabled = false
	$UI/Control/button/extend/run.disabled = false
	$UI/Control/button/extend/attack.disabled = false
	#切换为战斗界面
	$UI/Control/button/skill.visible = true
	$UI/Control/button/change_character.visible = false
	$UI/Control/button/choose_player_character.visible = false
	judge_skill_enable()

#region 因死亡而切换角色
#死亡后切换角色
func die_to_change_character(audio:bool = true) -> void:
	print("因死亡而切换角色")
	if audio:
		$audio/button.play()
	#重置为禁用切换角色按钮
	$UI/Control/button/extend/fight.disabled = false
	$UI/Control/button/extend/character.disabled = true
	$UI/Control/button/extend/run.disabled = false
	$UI/Control/button/extend/attack.disabled = false
	#切换为切换角色界面
	$UI/Control/button/skill.visible = false
	$UI/Control/button/change_character.visible = true
	refresh_change_character_button()

func _change_character_1(audio:bool = true) -> void:
	if audio:
		$audio/button.play()
	if player_character_curr != player_character_1:
		if not player_character_curr.dying:
			active_exit_animation(player_character_curr)
		player_character_curr = player_character_1
		disable_all_change_character_button()
		disable_all_extend_and_skill_buttons()
	addlog("玩家切换角色至 "+player_character_curr.character_name)
	active_enter_animation(player_character_curr)
	_to_fight(false)
	refresh_stat_ui()
	refresh_skill_button()
	someone_is_die -= 1

func _change_character_2(audio:bool = true) -> void:
	if audio:
		$audio/button.play()
	if player_character_curr != player_character_2:
		if not player_character_curr.dying:
			active_exit_animation(player_character_curr)
		player_character_curr = player_character_2
		disable_all_change_character_button()
		disable_all_extend_and_skill_buttons()
	addlog("玩家切换角色至 "+player_character_curr.character_name)
	active_enter_animation(player_character_curr)
	_to_fight(false)
	refresh_stat_ui()
	refresh_skill_button()
	someone_is_die -= 1

func _change_character_3(audio:bool = true) -> void:
	if audio:
		$audio/button.play()
	if player_character_curr != player_character_3:
		if not player_character_curr.dying:
			active_exit_animation(player_character_curr)
		player_character_curr = player_character_3
		disable_all_change_character_button()
		disable_all_extend_and_skill_buttons()
	addlog("玩家切换角色至 "+player_character_curr.character_name)
	active_enter_animation(player_character_curr)
	_to_fight(false)
	refresh_stat_ui()
	refresh_skill_button()
	someone_is_die -= 1

func _change_character_4(audio:bool = true) -> void:
	if audio:
		$audio/button.play()
	if player_character_curr != player_character_4:
		if not player_character_curr.dying:
			active_exit_animation(player_character_curr)
		player_character_curr = player_character_4
		disable_all_change_character_button()
		disable_all_extend_and_skill_buttons()
	addlog("玩家切换角色至 "+player_character_curr.character_name)
	active_enter_animation(player_character_curr)
	_to_fight(false)
	refresh_stat_ui()
	refresh_skill_button()
	someone_is_die -= 1
#endregion

#ai切换角色
#func ai_to_change_character():
	#print("ai切换角色")
	#await get_tree().create_timer(ai_think_time).timeout
	#if enemy_character_1 != null and not enemy_character_1.is_die:
		#enemy_character_curr = enemy_character_1
		#active_enter_animation(enemy_character_curr)
		#addlog("敌方切换角色至 "+enemy_character_curr.character_name)
	#elif enemy_character_2 != null and not enemy_character_2.is_die:
		#enemy_character_curr = enemy_character_2
		#active_enter_animation(enemy_character_curr)
		#addlog("敌方切换角色至 "+enemy_character_curr.character_name)
	#elif enemy_character_3 != null and not enemy_character_3.is_die:
		#enemy_character_curr = enemy_character_3
		#active_enter_animation(enemy_character_curr)
		#addlog("敌方切换角色至 "+enemy_character_curr.character_name)
	#elif enemy_character_4 != null and not enemy_character_4.is_die:
		#enemy_character_curr = enemy_character_4
		#active_enter_animation(enemy_character_curr)
		#addlog("敌方切换角色至 "+enemy_character_curr.character_name)
	#someone_is_die -= 1
	##skip_enemy_next_phase = true
	##print("skip_enemy_next_phase的值已被切换为true，跳过敌方下个回合")
	#refresh_stat_ui()
	##Signals.to_next_phase.emit()

func ai_to_change_character():
	print("ai切换角色")
	await get_tree().create_timer(ai_think_time).timeout
	var best_change_character
	var mul_is_1 = []
	var mul_is_1_25 = []
	var mul_is_1_5 = []
	for has_character in enemy_team:
		if not has_character.is_die:
			if has_character.get_element_multiplier(has_character.element,player_character_curr.element) == 1:
				mul_is_1.append(has_character)
			if has_character.get_element_multiplier(has_character.element,player_character_curr.element) == 1.25:
				mul_is_1_25.append(has_character)
			if has_character.get_element_multiplier(has_character.element,player_character_curr.element) == 1.5:
				mul_is_1_5.append(has_character)
		if mul_is_1_5.size() > 0:
			var best_character = mul_is_1_5[0]
			for the_character in mul_is_1_5:
				if the_character.curr_hp > best_character.curr_hp:
					best_character = the_character
			best_change_character = best_character
		elif mul_is_1_25.size() > 0:
			var best_character = mul_is_1_25[0]
			for the_character in mul_is_1_25:
				if the_character.curr_hp > best_character.curr_hp:
					best_character = the_character
			best_change_character = best_character
		elif mul_is_1.size() > 0:
			var best_character = mul_is_1[0]
			for the_character in mul_is_1:
				if the_character.curr_hp > best_character.curr_hp:
					best_character = the_character
			best_change_character = best_character
				

	if best_change_character == enemy_character_1:
		ai_change_character_1()
	if best_change_character == enemy_character_2:
		ai_change_character_2()
	if best_change_character == enemy_character_3:
		ai_change_character_3()
	if best_change_character == enemy_character_4:
		ai_change_character_4()
	refresh_stat_ui()
	Signals.to_next_phase.emit()
	
func ai_change_character_1() -> void:
	if enemy_character_curr != enemy_character_1:
		if not enemy_character_curr.dying:
			active_exit_animation(enemy_character_curr)
		enemy_character_curr = enemy_character_1
	addlog("敌方切换角色至 "+enemy_character_curr.character_name)
	active_enter_animation(enemy_character_curr)
	refresh_stat_ui()
	someone_is_die -= 1
func ai_change_character_2() -> void:
	if enemy_character_curr != enemy_character_2:
		if not enemy_character_curr.dying:
			active_exit_animation(enemy_character_curr)
		enemy_character_curr = enemy_character_2
	addlog("敌方切换角色至 "+enemy_character_curr.character_name)
	active_enter_animation(enemy_character_curr)
	refresh_stat_ui()
	someone_is_die -= 1
func ai_change_character_3() -> void:
	if enemy_character_curr != enemy_character_3:
		if not enemy_character_curr.dying:
			active_exit_animation(enemy_character_curr)
		enemy_character_curr = enemy_character_3
	addlog("敌方切换角色至 "+enemy_character_curr.character_name)
	active_enter_animation(enemy_character_curr)
	refresh_stat_ui()
	someone_is_die -= 1
func ai_change_character_4() -> void:
	if enemy_character_curr != enemy_character_4:
		if not enemy_character_curr.dying:
			active_exit_animation(enemy_character_curr)
		enemy_character_curr = enemy_character_4
	addlog("敌方切换角色至 "+enemy_character_curr.character_name)
	active_enter_animation(enemy_character_curr)
	refresh_stat_ui()
	someone_is_die -= 1

#判断技能能否使用
func judge_skill_enable():
	#禁用能量不够的技能，启用能量足够的技能
	if player_character_curr.skilla_energy > player_character_curr.curr_energy:
		$UI/Control/button/skill/skilla.disabled = true
	else:
		$UI/Control/button/skill/skilla.disabled = false
	if player_character_curr.skillb_energy > player_character_curr.curr_energy:
		$UI/Control/button/skill/skillb.disabled = true
	else:
		$UI/Control/button/skill/skillb.disabled = false
	if player_character_curr.skillc_energy > player_character_curr.curr_energy:
		$UI/Control/button/skill/skillc.disabled = true
	else:
		$UI/Control/button/skill/skillc.disabled = false
	if player_character_curr.skilld_energy > player_character_curr.curr_energy:
		$UI/Control/button/skill/skilld.disabled = true
	else:
		$UI/Control/button/skill/skilld.disabled = false


func _run() -> void:
	get_tree().change_scene_to_file("uid://b54hfqxogsgfm")

#普攻
func _attack(audio:bool = true) -> void:
	if audio:
		$audio/button.play()
	player_character_curr.attack(enemy_character_curr,player_character_curr,enemy_team,player_team)
	judge_skill_enable()
	disable_all_extend_and_skill_buttons()

#禁用所有侧边按钮和技能按钮
func disable_all_extend_and_skill_buttons():
	$UI/Control/button/extend/fight.disabled = true
	$UI/Control/button/extend/character.disabled = true
	$UI/Control/button/extend/run.disabled = true
	$UI/Control/button/extend/attack.disabled = true
	$UI/Control/button/skill/skilla.disabled = true
	$UI/Control/button/skill/skillb.disabled = true
	$UI/Control/button/skill/skillc.disabled = true
	$UI/Control/button/skill/skilld.disabled = true

#切换回合
#定义新一轮标记
var new_round:bool = false

#防止多次执行下一回合函数
var is_to_next_phase = false
func to_next_phase():
	if is_to_next_phase:
		return
	is_to_next_phase = true
	#ai持续行动
	if ai_continue_action:
		judge_character_die()
		while someone_is_die>0:
			if not get_tree():
				break
			await get_tree().physics_frame
		print("ai连续行动")
		ai_continue_action = false
		is_to_next_phase = false
		ai_enemy_action()
		return
	refresh_ai()
	new_round = false
	#总回合数+1
	Global.curr_phase_count += 1
	if Global.curr_phase_count % 2 != 0:
		#轮次+1并标记新一轮用于根据速度决定先后手
		Global.curr_round_count += 1
		new_round = true
		#发送新一轮信号（改为判定完新一轮先手后发送）
		#print("发送下一轮信号")
		#Signals.round_start.emit()
	judge_character_die()
	while someone_is_die>0:
		if not get_tree():
			break
		await get_tree().physics_frame
	if new_round:
		speed_to_judge_phase()
		new_round = false
	else:
		if curr_phase == "player":
			if not skip_enemy_next_phase:
				print("正常进入敌方回合")
				#是否回合被跳过
				if enemy_character_curr.skip_next_phase:
					print("敌方回合被技能跳过")
					enemy_character_curr.skip_next_phase = false
					addlog(enemy_character_curr.character_name+" 回合被跳过")
					is_to_next_phase = false #不调为false下面新回合的信号不会生效
					Signals.to_next_phase.emit()
				else:
					curr_phase = "enemy"
					disable_all_extend_and_skill_buttons()
					ai_enemy_action()
			else:
				print("敌方跳过一回合，进入我方回合")
				if player_character_curr.skip_next_phase:
					print("我方回合被技能跳过")
					player_character_curr.skip_next_phase = false
					addlog(player_character_curr.character_name+" 回合被跳过")
					is_to_next_phase = false #不调为false下面新回合的信号不会生效
					Signals.to_next_phase.emit()
				else:
					curr_phase = "player"
					_to_fight(false)
				#region防止胜利后还可以操作
				if enemy_character_curr.dying:
					print("击杀敌方后已禁用技能")
					disable_all_extend_and_skill_buttons()
				#endregion
				skip_enemy_next_phase = false
		elif curr_phase == "enemy":
			if player_character_curr.skip_next_phase:
				print("我方回合被技能跳过")
				player_character_curr.skip_next_phase = false
				addlog(player_character_curr.character_name+" 回合被跳过")
				is_to_next_phase = false #不调为false下面新回合的信号不会生效
				Signals.to_next_phase.emit()
			else:
				print("正常进入我方回合")
				curr_phase = "player"
				_to_fight(false)
		else:
			printerr("不知道是谁的回合！")
	
	is_to_next_phase = false

#敌方ai行动
func ai_enemy_action():
	_physics_process(0.001)
	if get_tree():
		await get_tree().create_timer(ai_think_time).timeout
	while Global.playing_animation_time > 0:
		if not get_tree():
			break
		await get_tree().physics_frame
	enemy_character_curr.ai_action(player_character_curr,enemy_character_curr,player_team,enemy_team)

#主动退场动画
func active_exit_animation(character):
	if Global.playing_animation_time < 1.5:
		Global.playing_animation_time = 1.5
	print(character.character_name,"退场动画",character.get_node("Sprite2D").position)
	var tween = create_tween()  # 自动创建并绑定Tween节点
	#需要使用 parallel() 让两个动画同时执行（否则会按顺序执行）
	tween.parallel().tween_property(character.get_node("Sprite2D"), "scale", Vector2(5,5), 0.5)
	tween.parallel().tween_property(character.get_node("Sprite2D"), "modulate:a", 0.0, 0.5)
	#tween.parallel().tween_property(character.get_node("Sprite2D"), "position",
	#character.get_node("Sprite2D").position + Vector2(0,1200), 
	#0.5
	#)
	await get_tree().create_timer(animation_wait_time).timeout
	character.get_node("Sprite2D").visible = false
	#character.get_node("Sprite2D").position -= Vector2(0,1200)
	
#主动入场动画并执行入场函数
func active_enter_animation(character):
	character.enter()
	if Global.playing_animation_time < 1.5:
		Global.playing_animation_time = 1.5
	print(character.character_name,"入场动画",character.get_node("Sprite2D").position)
	var tween = create_tween()
	character.get_node("Sprite2D").visible = true
	character.get_node("Sprite2D").scale = Vector2(5, 5)
	character.get_node("Sprite2D").modulate = Color(1, 1, 1, 0)
	#character.get_node("Sprite2D").position += Vector2(0,1200)
	tween.parallel().tween_property(character.get_node("Sprite2D"), "scale", Vector2(0.6,0.6), 0.5)
	tween.parallel().tween_property(character.get_node("Sprite2D"), "modulate:a", 1.0, 0.5)
	#tween.parallel().tween_property(character.get_node("Sprite2D"), "position",
	#character.get_node("Sprite2D").position - Vector2(0,1200), 
	#0.5
	#)

#死亡退场动画
func active_die_animation(character):
	if Global.playing_animation_time < 1.5:
		Global.playing_animation_time = 1.5
	print(character.character_name,"死亡退场动画",character.get_node("Sprite2D").position)
	var tween = create_tween()  # 自动创建并绑定Tween节点
	#需要使用 parallel() 让两个动画同时执行（否则会按顺序执行）
	tween.parallel().tween_property(character.get_node("Sprite2D"), "scale", Vector2(5,5), 0.5)
	tween.parallel().tween_property(character.get_node("Sprite2D"), "modulate:a", 0.0, 0.5)
	#tween.parallel().tween_property(character.get_node("Sprite2D"), "position",
	#character.get_node("Sprite2D").position + Vector2(0,1200), 
	#0.5
	#)
	if get_tree():
		await get_tree().create_timer(animation_wait_time).timeout
	character.get_node("Sprite2D").visible = false
	#character.get_node("Sprite2D").position -= Vector2(0,1200)


#禁用所有切换角色按钮
func disable_all_change_character_button():
	$UI/Control/button/change_character/character1.disabled = true
	$UI/Control/button/change_character/character2.disabled = true
	$UI/Control/button/change_character/character3.disabled = true
	$UI/Control/button/change_character/character4.disabled = true

#刷新名字属性的信息ui
func refresh_stat_ui():
	#刷新我方UI属性
	$UI/Control/player1_stat/element.text = player_character_curr.element_info.get(player_character_curr.element, {"name":"未知"})["name"] +" "
	$UI/Control/player1_stat/element.add_theme_color_override("font_color",player_character_curr.element_info.get(player_character_curr.element, {"color": Color(1, 1, 1)})["color"])
	#刷新我方UI名字
	$UI/Control/player1_stat/name.text = player_character_curr.character_name
	#刷新敌方UI属性
	$UI/Control/player2_stat/element.text = " " + enemy_character_curr.element_info.get(enemy_character_curr.element, {"name":"未知"})["name"]
	$UI/Control/player2_stat/element.add_theme_color_override("font_color",player_character_curr.element_info.get(enemy_character_curr.element, {"color": Color(1, 1, 1)})["color"])
	#刷新敌方UI名字
	$UI/Control/player2_stat/name.text = enemy_character_curr.character_name

func refresh_skill_button():
	#刷新技能信息
	$UI/Control/button/skill/skilla/name.text = player_character_curr.skilla_name
	$UI/Control/button/skill/skilla/other.text = (player_character_curr.damage_type_info.get(player_character_curr.skilla_damage_type, {"name":"未知"})["name"]+" 耗能"+str(player_character_curr.skilla_energy))
	$UI/Control/button/skill/skilla/other.add_theme_color_override("font_color",player_character_curr.element_info.get(player_character_curr.skilla_element, {"color": Color(1, 1, 1)})["color"])
	
	$UI/Control/button/skill/skillb/name.text = player_character_curr.skillb_name
	$UI/Control/button/skill/skillb/other.text = (player_character_curr.damage_type_info.get(player_character_curr.skillb_damage_type, {"name":"未知"})["name"]+" 耗能"+str(player_character_curr.skillb_energy))
	$UI/Control/button/skill/skillb/other.add_theme_color_override("font_color",player_character_curr.element_info.get(player_character_curr.skillb_element, {"color": Color(1, 1, 1)})["color"])
	
	$UI/Control/button/skill/skillc/name.text = player_character_curr.skillc_name
	$UI/Control/button/skill/skillc/other.text = (player_character_curr.damage_type_info.get(player_character_curr.skillc_damage_type, {"name":"未知"})["name"]+" 耗能"+str(player_character_curr.skillc_energy))
	$UI/Control/button/skill/skillc/other.add_theme_color_override("font_color",player_character_curr.element_info.get(player_character_curr.skillc_element, {"color": Color(1, 1, 1)})["color"])

	$UI/Control/button/skill/skilld/name.text = player_character_curr.skilld_name
	$UI/Control/button/skill/skilld/other.text = (player_character_curr.damage_type_info.get(player_character_curr.skilld_damage_type, {"name":"未知"})["name"]+" 耗能"+str(player_character_curr.skilld_energy))
	$UI/Control/button/skill/skilld/other.add_theme_color_override("font_color",player_character_curr.element_info.get(player_character_curr.skilld_element, {"color": Color(1, 1, 1)})["color"])

	#刷新技能描述
	refresh_skill_description()

func judge_character_die():
	#判断角色死亡以及胜负
	if player_character_curr.curr_hp <= 0 and not player_character_curr.dying:
		player_character_curr.dying = true
		player_team_alive -= 1
		someone_is_die += 1
		player_character_curr.die()
		active_die_animation(player_character_curr)
		die_to_change_character(false)
		disable_all_extend_and_skill_buttons()
		refresh_team_stat()
		print("————————————")
		print(player_character_curr.character_name," 死亡！")
		print("————————————")
		addlog("[color=dark_red]"+player_character_curr.character_name+" 死亡！"+"[/color]")
		if player_team_alive <= 0:
			print("gameover,enegy win")
			$audio/BGM.stream_paused = true
			$audio/Fail.play()
			player_fail()
		return true
	if enemy_character_curr.curr_hp <= 0 and not enemy_character_curr.dying:
		enemy_character_curr.dying = true
		enemy_team_alive -= 1
		someone_is_die += 1
		enemy_character_curr.die()
		active_die_animation(enemy_character_curr)
		ai_to_change_character()
		refresh_team_stat()
		print("————————————")
		print(enemy_character_curr.character_name," 死亡！")
		print("————————————")
		addlog("[color=dark_red]"+enemy_character_curr.character_name+" 死亡！"+"[/color]")
		if enemy_team_alive <= 0:
			print("gameover,player win")
			$audio/BGM.stream_paused = true
			$audio/Win.play()
			disable_all_extend_and_skill_buttons()
			Global.playing_animation_time += 3
			player_win()
		return true
		
	#判断场下角色的死亡
	for character in player_team:
		if character.curr_hp <= 0 and character != player_character_curr and not character.dying:
			character.dying = true
			player_team_alive -= 1
			character.die()
			print("————————————")
			print("场下的",character.character_name," 死亡！")
			print("————————————")
			refresh_team_stat()
			addlog("[color=dark_red]场下的 "+character.character_name+" 死亡！"+"[/color]")
	for character in enemy_team:
		if character.curr_hp <= 0 and character != enemy_character_curr and not character.dying:
			character.dying = true
			enemy_team_alive -= 1
			character.die()
			print("————————————")
			print("场下的",character.character_name," 死亡！")
			print("————————————")
			refresh_team_stat()
			addlog("[color=dark_red]场下的 "+character.character_name+" 死亡！"+"[/color]")
		
#刷新当前回合以及轮次ui
func refresh_phase_round_ui():
	if curr_phase == "player":
		$UI/Control/curr_phase.text = "我方回合"
		$UI/Control/curr_phase.add_theme_color_override("font_color",Color.DARK_GREEN)
		
	elif curr_phase == "enemy":
		$UI/Control/curr_phase.text = "敌方回合"
		$UI/Control/curr_phase.add_theme_color_override("font_color",Color.DARK_RED)
	
	$UI/Control/curr_round_count.text = "第 "+str(Global.curr_round_count)+" 轮"

func init_position_and_scale():
	#修改角色与敌人的位置与卡牌大小为默认
	for character in player_team:
		if character:
			var sprite = character.get_node("Sprite2D")
			sprite.scale = player_scale
			sprite.position = player_position
	for character in enemy_team:
		if character:
			var sprite = character.get_node("Sprite2D")
			sprite.scale = enemy_scale
			sprite.position = enemy_position
			#水平镜像翻转
			sprite.flip_h = true

#动画开始时禁用按钮，动画结束后解禁
func begin_animation():
	disable_all_extend_and_skill_buttons()
	while someone_is_die > 0:
		if not get_tree():
			break
		await get_tree().physics_frame
	disable_all_change_character_button()
	while Global.playing_animation_time > 0:
		if not get_tree():
			break
		await get_tree().physics_frame
	judge_skill_enable()
	refresh_change_character_button()
	if not player_character_curr.dying:
		_to_fight(false)

#刷新角色按钮
func refresh_change_character_button():
	#先允许所有角色按钮
	$UI/Control/button/change_character/character1.disabled = false
	$UI/Control/button/change_character/character2.disabled = false
	$UI/Control/button/change_character/character3.disabled = false
	$UI/Control/button/change_character/character4.disabled = false
	#切换为不可切换为当前的站场角色
	if player_character_curr == player_character_1:
		$UI/Control/button/change_character/character1.disabled = true
	if player_character_curr == player_character_2:
		$UI/Control/button/change_character/character2.disabled = true
	if player_character_curr == player_character_3:
		$UI/Control/button/change_character/character3.disabled = true
	if player_character_curr == player_character_4:
		$UI/Control/button/change_character/character4.disabled = true
	#不可切换为空角色
	if player_character_1 == null:
		$UI/Control/button/change_character/character1.disabled = true
	if player_character_2 == null:
		$UI/Control/button/change_character/character2.disabled = true
	if player_character_3 == null:
		$UI/Control/button/change_character/character3.disabled = true
	if player_character_4 == null:
		$UI/Control/button/change_character/character4.disabled = true
	#不可切换为阵亡角色
	if player_character_1 != null and player_character_1.is_die:
		$UI/Control/button/change_character/character1.disabled = true
	if player_character_2 != null and player_character_2.is_die:
		$UI/Control/button/change_character/character2.disabled = true
	if player_character_3 != null and player_character_3.is_die:
		$UI/Control/button/change_character/character3.disabled = true
	if player_character_4 != null and player_character_4.is_die:
		$UI/Control/button/change_character/character4.disabled = true

#刷新技能描述
func refresh_skill_description():
	print("已刷新描述")
	Global.fighting_skilla_description = player_character_curr.skilla_description
	Global.fighting_skillb_description = player_character_curr.skillb_description
	Global.fighting_skillc_description = player_character_curr.skillc_description
	Global.fighting_skilld_description = player_character_curr.skilld_description

func addlog(text,is_gray = false):
	if not is_gray:
		log.text += "\n"+str(text)
	else:
		log.text += "\n"+"[color=gray]"+str(text)+"[/color]"
	
#先定义一个变量储存选择角色
var choice_player_character
#选择角色，默认玩家方，若为ai则跳转另一方法
func choose_team_character(who,is_skill:bool = false,can_self:bool = true,can_die:bool = false):
	if who.is_ai:
		print("技能触发的选择敌方角色")
		return ai_choose_team_character(can_self,can_die)
	if is_skill:
		print("技能触发的选择玩家方角色")
		disable_all_extend_and_skill_buttons()
	else:
		print("UI触发的选择玩家方角色")
		$UI/Control/button/extend/fight.disabled = false
		$UI/Control/button/extend/character.disabled = true
	#展示选择界面
	$UI/Control/button/change_character.visible = false
	$UI/Control/button/skill.visible = false
	$UI/Control/button/choose_player_character.visible = true
	#筛选可选择目标
	#先全部允许选择
	$UI/Control/button/choose_player_character/character1.disabled = false
	$UI/Control/button/choose_player_character/character2.disabled = false
	$UI/Control/button/choose_player_character/character3.disabled = false
	$UI/Control/button/choose_player_character/character4.disabled = false
	#不可选择空置
	if not player_character_1:
		$UI/Control/button/choose_player_character/character1.disabled = true
	if not player_character_2:
		$UI/Control/button/choose_player_character/character2.disabled = true
	if not player_character_3:
		$UI/Control/button/choose_player_character/character3.disabled = true
	if not player_character_4:
		$UI/Control/button/choose_player_character/character4.disabled = true
	#不可选择死亡
	if not can_die:
		if player_character_1 and player_character_1.is_die:
			$UI/Control/button/choose_player_character/character1.disabled = true
		if player_character_2 and player_character_2.is_die:
			$UI/Control/button/choose_player_character/character2.disabled = true
		if player_character_3 and player_character_3.is_die:
			$UI/Control/button/choose_player_character/character3.disabled = true
		if player_character_4 and player_character_4.is_die:
			$UI/Control/button/choose_player_character/character4.disabled = true
	#不可选择自己（当前站场角色）
	if not can_self:
		if player_character_curr == player_character_1:
			$UI/Control/button/choose_player_character/character1.disabled = true
		if player_character_curr == player_character_2:
			$UI/Control/button/choose_player_character/character2.disabled = true
		if player_character_curr == player_character_3:
			$UI/Control/button/choose_player_character/character3.disabled = true
		if player_character_curr == player_character_4:
			$UI/Control/button/choose_player_character/character4.disabled = true
	#如果没有可选目标
	if $UI/Control/button/choose_player_character/character1.disabled and $UI/Control/button/choose_player_character/character2.disabled and $UI/Control/button/choose_player_character/character3.disabled and $UI/Control/button/choose_player_character/character4.disabled:
		print("没有可选目标！")
		return null
	#等待选择目标
	choice_player_character = null
	while choice_player_character == null:
		if get_tree():
			await get_tree().process_frame
	#等待完毕
	$UI/Control/button/choose_player_character.visible = false
	_to_fight(false)
	#返回值
	return choice_player_character
	
func choose_player_team_character_1():
	choice_player_character = player_character_1
	
func choose_player_team_character_2():
	choice_player_character = player_character_2
	
func choose_player_team_character_3():
	choice_player_character = player_character_3
	
func choose_player_team_character_4():
	choice_player_character = player_character_4
	
func choose_player_team_character_none():
	print("没有选择角色！")
	choice_player_character = "none"

#技能触发的选择角色，AI默认选择适合上场的角色
func ai_choose_team_character(can_self:bool = true,can_die:bool = false):
	#敌方角色列表
	var character_list = [
		enemy_character_1,
		enemy_character_2,
		enemy_character_3,
		enemy_character_4
	]
	# 筛选符合条件的角色
	var can_be_target = []
	for character in character_list:
		# 跳过空引用
		if not character:
			continue
		# 检查是否允许选择已死亡角色
		if not can_die and character.is_die:
			continue
		# 检查是否允许选择自己（如果有self角色的判断需求）
		if not can_self and character == enemy_character_curr:
			continue
		# 符合条件的加入候选列表
		can_be_target.append(character)
	
	#判断属性克制选择适合应对敌方的角色
	var best_change_value = -INF
	var best_change_character = null
	var change_value
	for character in enemy_team:
		change_value = 0
		if character == enemy_character_curr or character.is_die:
			continue
		if character.get_element_multiplier(character.element,player_character_curr.element) == 0.5:
			change_value -= 10 * character.curr_hp / character.max_hp
		if character.get_element_multiplier(character.element,player_character_curr.element) == 0.75:
			change_value -= 5 * character.curr_hp / character.max_hp
		if character.get_element_multiplier(character.element,player_character_curr.element) == 1:
			change_value -= 0
		if character.get_element_multiplier(character.element,player_character_curr.element) == 1.25:
			change_value += 5 * character.curr_hp / character.max_hp
		if character.get_element_multiplier(character.element,player_character_curr.element) == 1.5:
			change_value += 10 * character.curr_hp / character.max_hp
		if change_value > best_change_value:
			best_change_value = change_value
			best_change_character = character
		return best_change_character
	
	#根据速度决定当前回合
func speed_to_judge_phase():
	print("依据速度决定先后手！")
	#判断先后手
	if player_character_curr.speed > enemy_character_curr.speed:
		curr_phase = "player"
		if not player_character_curr.skip_next_phase:
			_to_fight(false)
	elif player_character_curr.speed < enemy_character_curr.speed:
		curr_phase = "enemy"
		if not enemy_character_curr.skip_next_phase:
			disable_all_extend_and_skill_buttons()
			ai_enemy_action()
	elif player_character_curr.speed == enemy_character_curr.speed:
		var random = randi_range(0,1)
		if random == 0:
			curr_phase = "player"
			if not player_character_curr.skip_next_phase:
				_to_fight(false)
		else:
			curr_phase = "enemy"
			if not enemy_character_curr.skip_next_phase:
				disable_all_extend_and_skill_buttons()
				ai_enemy_action()
	print(curr_phase,"为先手！")
	if curr_phase == "player":
		addlog("——————————————————\n本轮轮先手为 我方")
	if curr_phase == "enemy":
		addlog("——————————————————\n本轮轮先手为 对方")
	if (Global.curr_round_count) % 10 == 0:
		addlog("十轮触发：火力全开，伤害提升！",true)
		
	#发送下一轮信号
	Signals.round_start.emit()
		
	#判断是否跳过回合
	if player_character_curr.skip_next_phase and curr_phase == "player":
		print("我方回合被技能跳过")
		player_character_curr.skip_next_phase = false
		addlog(player_character_curr.character_name+" 回合被跳过")
		is_to_next_phase = false #不调为false下面新回合的信号不会生效
		Signals.to_next_phase.emit()
	if enemy_character_curr.skip_next_phase and curr_phase == "enemy":
		print("敌方回合被技能跳过")
		enemy_character_curr.skip_next_phase = false
		addlog(enemy_character_curr.character_name+" 回合被跳过")
		is_to_next_phase = false #不调为false下面新回合的信号不会生效
		Signals.to_next_phase.emit()

func refresh_ai():
	player_character_curr.refresh_ai(enemy_character_curr,player_character_curr,enemy_team,player_team)
	enemy_character_curr.refresh_ai(player_character_curr,enemy_character_curr,player_team,enemy_team)
	print("已刷新双方AI决策信息")

func change_character_to(who):
	if who == player_character_1:
		_change_character_1()
	if who == player_character_2:
		_change_character_2()
	if who == player_character_3:
		_change_character_3()
	if who == player_character_4:
		_change_character_4()
	if who == enemy_character_1:
		ai_change_character_1()
	if who == enemy_character_2:
		ai_change_character_2()
	if who == enemy_character_3:
		ai_change_character_3()
	if who == enemy_character_4:
		ai_change_character_4()

func player_win():
	var ui = $UI/Control/player_win
	ui.modulate = Color(1, 1, 1, 0)
	ui.scale = Vector2(0.5, 0.5)
	ui.visible = true
	var tween = create_tween()
	tween.parallel().tween_property(ui, "modulate:a", 1.0, 0.2)
	tween.parallel().tween_property(ui, "scale", Vector2(1,1), 0.2)
	move_log_position()

func player_fail():
	var ui = $UI/Control/player_fail
	ui.modulate = Color(1, 1, 1, 0)
	ui.scale = Vector2(0.5, 0.5)
	ui.visible = true
	var tween = create_tween()
	tween.parallel().tween_property(ui, "modulate:a", 1.0, 0.2)
	tween.parallel().tween_property(ui, "scale", Vector2(1,1), 0.2)
	move_log_position()

#用于胜利后将log移至左侧
func move_log_position():
	var log = $UI/Control/log
	var tween = create_tween()
	tween.tween_property(log,"position", Vector2(-406,484), 0.2)

#刷新是否为站场角色
func refresh_is_curr():
	for character in player_team:
		if character != player_character_curr:
			character.is_curr = false
		else:
			character.is_curr = true
	for character in enemy_team:
		if character != enemy_character_curr:
			character.is_curr = false
		else:
			character.is_curr = true
