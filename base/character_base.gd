extends Node
class_name character_base

#组合ai文件
@onready var ai = FightingAI.new()
#ai所需参数
var skill_effects = {}

@export var character_name:String = "角色基类"

#特殊能量
@export var is_special_energy:bool = false

#伤害类型占比
@export var damage_phy_ratio:float = 100 ##物伤占比
@export var damage_mag_ratio:float = 0 ##法伤占比
@export var damage_real_ratio:float = 0 ##真伤占比

#是否为ai控制
var is_ai:bool = false

#是否为站场角色
var is_curr:bool = false

#是否上场过，用于ai判断是否上场过克制角色防止与玩家无限循环切换角色
var have_appear:bool = false

#受到致命伤害保留1点HP的剩余次数
var not_die_to_one_hp:int = 0

#是否有卖血状态，这是卖血倍率
var be_damage_to_benefit_mul:float = 1

#跳过下一回合
var skip_next_phase:bool = false

#嘲讽值，嘲讽值越高，ai越会优先打伤害
var taunt_value:float = 1.0

#冰冻,首层有60%的概率跳过回合，之后每层增加10%概率（最多5层，已在函数限制）。若大于1层，则无论是否解冻层数都-1；若解冻，则层数归零。
var ice_stacks:int = 0

#晕眩，跳过回合
var stun_stacks:int = 0

#灼烧，记录buff来源,回合开始掉血
var burning_phase:int = 0
var burning_source:character_base = null

#寄生，记录寄生buff来源的一半物攻
var parasitism_phase:int = 0;
var parasitism_power:int = 0;
var parasitism_watered_times:int = 0;

#睡眠/沉眠
var sleep_type:int = 0; #0为正常，1为睡眠，2为沉眠
var sleep_probability:int = 0;

#分类，例如非人一类 植物一类
var tags:Array[String] = []

func _init() -> void:
	#连接信号
	Signals.phase_begin.connect(phase_begin);

#region 属性信息
var element_info = {
	"metal": {
		"name": "金",
		"color": Color.GOLD  # 金色
	},
	"wood": {
		"name": "木",
		"color": Color.WEB_GREEN  # 绿色
	},
	"water": {
		"name": "水",
		"color": Color.ROYAL_BLUE  # 蓝色
	},
	"fire": {
		"name": "火",
		"color": Color.RED  # 红色
	},
	"earth": {
		"name": "土",
		"color": Color.SADDLE_BROWN  # 棕色
	}
}

#属性伤害倍率
var element_multiplier = {
	"metal": {
		"wood":1.5,
		"earth":1.25,
		"water":0.5,
		"fire":0.75,
		"metal":1,
	},
	"wood": {
		"earth":1.5,
		"water":1.25,
		"fire":0.5,
		"metal":0.75,
		"wood":1,
	},
	"water": {
		"fire":1.5,
		"metal":1.25,
		"wood":0.5,
		"earth":0.75,
		"water":1,
	},
	"fire": {
		"metal":1.5,
		"wood":1.25,
		"earth":0.5,
		"water":0.75,
		"fire":1,
	},
	"earth": {
		"water":1.5,
		"fire":1.25,
		"metal":0.5,
		"wood":0.75,
		"earth":1,
	},
}
#endregion

#技能描述
var skilla_description:String = "技能一暂无描述"
var skillb_description:String = "技能二暂无描述"
var skillc_description:String = "技能三暂无描述"
var skilld_description:String = "技能四暂无描述"
var skilla_short_desc:String = "技能一暂无简约描述"
var skillb_short_desc:String = "技能二暂无简约描述"
var skillc_short_desc:String = "技能三暂无简约描述"
var skilld_short_desc:String = "技能四暂无简约描述"

# 获取属性的中文名称和颜色
func get_element_name(element: String) -> String:
	return element_info.get(element, {"name": "未知"})["name"]

func get_element_color(element: String) -> Color:
	return element_info.get(element, {"color": Color(1, 1, 1)})["color"]

var damage_type_info = {
	"none": {
		"name": "功能",
	},
	"phy": {
		"name": "物伤",
	},
	"mag": {
		"name": "法伤",
	},
	"real": {
		"name": "真伤",
	},
	"mix": {
		"name": "混伤",
	},
}

#region 基础数值
@export var max_hp : int = 10000
@export var max_energy : int = 100

#region 局内数值
var curr_hp:int
var curr_energy:int
var damage_reduction:float = 0##免伤百分比
var damage_improve:float = 0##增伤百分比
#endregion

@export var element : String = "metal" ##属性：metal,fire,wood,water,earth

@export var speed : int = 100 ##速度
@export var physical_power : int = 100 ##物攻
@export var magical_power : int = 100 ##法强
@export var physical_defense : int = 100 ##物抗
@export var magical_defense : int = 100 ##魔抗

@export var shield : int = 0 ##护盾
#endregion

#region 技能相关
@export var skilla_name :String = "技能之一"
@export var skillb_name :String = "技能之二"
@export var skillc_name :String = "技能之三"
@export var skilld_name :String = "技能之四"
@export var skilla_energy :int = 5
@export var skillb_energy :int = 10
@export var skillc_energy :int = 20
@export var skilld_energy :int = 30
@export var skilla_element :String = "metal"
@export var skillb_element :String = "metal"
@export var skillc_element :String = "metal"
@export var skilld_element :String = "metal"
@export var skilla_damage_type :String = "none"
@export var skillb_damage_type :String = "none"
@export var skillc_damage_type :String = "none"
@export var skilld_damage_type :String = "none"
#endregion

#用于储存获取的父场景的日志节点
var log:RichTextLabel
#是否处于濒死，用于防止濒死状态继续执行回合判断函数
var dying = false
#是否死亡
var is_die = false

#轮次伤害倍率，防止轮次被拖长
var round_damage_mul = 1
func _process(delta: float) -> void:
	#轮次伤害倍率，防止轮次被拖长
	round_damage_mul = 1 + 0.2*(Global.curr_round_count/10)

func _ready() -> void:
	curr_hp = max_hp
	curr_energy = max_energy*0.5
	#获取父场景的日志节点
	log = get_node("../UI/Control/log/VBoxContainer/PanelContainer/MarginContainer/RichTextLabel")
	
func skilla(enemy,player,enemy_team,player_team):
	print("释放一技能")
	curr_energy -= skilla_energy
	curr_energy = max(0,curr_energy)
	addlog(character_name+" 释放 "+"[hint="+skilla_short_desc+"]"+skilla_name+"[/hint]")
	
func skillb(enemy,player,enemy_team,player_team):
	print("释放二技能")
	curr_energy -= skillb_energy
	curr_energy = max(0,curr_energy)
	addlog(character_name+" 释放 "+"[hint="+skillb_short_desc+"]"+skillb_name+"[/hint]")
	
func skillc(enemy,player,enemy_team,player_team):
	print("释放三技能")
	curr_energy -= skillc_energy
	curr_energy = max(0,curr_energy)
	addlog(character_name+" 释放 "+"[hint="+skillc_short_desc+"]"+skillc_name+"[/hint]")
	
func skilld(enemy,player,enemy_team,player_team):
	print("释放四技能")
	curr_energy -= skilld_energy
	curr_energy = max(0,curr_energy)
	addlog(character_name+" 释放 "+"[hint="+skilld_short_desc+"]"+skilld_name+"[/hint]")
	
func attack(enemy,player,enemy_team,player_team):
	addlog(character_name+"释放普攻")
	print("释放普攻")
	enemy.be_damage(damage(100,"phy",enemy,element),player,"phy",element)
	to_damage(damage(100,"phy",enemy,element),enemy,"phy",element,false,10)
	attack_skill_animation()
	Signals.to_next_phase.emit()
	print("普攻，于基类中触发下一回合信号")
	
#受到伤害
func be_damage(damage,source,damage_type:String,damage_element:String,is_extra:bool = false,energy = int(round(damage/100.0))):
	#睡眠惊醒
	if sleep_type == 1:
		addlog(character_name+" 从睡眠中惊醒！")
		sleep_type = 0;
	#解除冰冻
	if damage_element == "fire" and ice_stacks>0:
		ice_stacks = 0
		print("受到火焰伤害解除冰冻")
		addlog("冻住 "+character_name+" 的冰被高温融化了")
	#触发蒸发效果，解除灼烧，并造成蒸发伤害
	if damage_element == "water" and burning_phase>0:
		var log_burning_phase = burning_phase;
		burning_phase = 0
		print("受到水伤害解除灼烧")
		addlog(character_name+" 的灼烧被蒸发了")
		be_and_to_damage(damage(burning_source.magical_power*log_burning_phase,"mag",self,"fire"),self,burning_source,"mag","fire")
	#触发点燃效果，将寄生转化为灼烧
	if damage_element == "fire" and parasitism_phase>0:
		addlog(character_name+" 的寄生被点燃了")
		burn(parasitism_phase+1,source);
		parasitism_phase = 0;
	#触发灌溉效果，提升寄生数组
	if damage_element == "water" and parasitism_phase>0:
		if parasitism_watered_times < 2:
			addlog(character_name+" 的寄生被灌溉了")
			parasitism_power = int(parasitism_power*1.5);
	
	#原本的生命值，用于计算溢出伤害
	var origin_hp = curr_hp
	#护盾
	if shield > 0 and damage_type!="real":
		var shield_absorbed = min(damage,shield)#护盾吸收的伤害量
		shield -= shield_absorbed
		damage -= shield_absorbed
		addlog(character_name+" 的护盾吸收了"+str(shield_absorbed)+"点伤害")
		print("护盾吸收了",shield_absorbed,"点伤害")
	if not_die_to_one_hp > 0:
		if damage >= curr_hp:
			damage = curr_hp-1
			not_die_to_one_hp -= 1
			not_die_to_one_hp = max(not_die_to_one_hp,0)
	curr_hp -= damage
	curr_energy += energy
	curr_energy = clamp(curr_energy,0,max_energy)
	#print(character_name," 受到 ",damage,"点",damage_type_info.get(damage_type,{"name"="未知"})["name"],element_info.get(damage_element,{"name"="未知"})["name"],"伤害，获得",energy,"点能量，","伤害来源为 ",source.character_name)
	#print(character_name," 当前血量为",curr_hp,"，当前能量为",curr_energy)
	#print("————————————————————————————————————————")
	if damage>0:
		addlog(character_name+" 受到"+str(damage)+"点"+damage_type_info.get(damage_type,{"name"="未知"})["name"]+element_info.get(damage_element,{"name"="未知"})["name"]+"属性伤害")
	if (origin_hp-damage) < 0:
		addlog(character_name+" HP达到0，溢出"+str(damage-origin_hp)+"点伤害")
	
#造成伤害
func to_damage(damage,target,damage_type:String,damage_element:String,is_extra:bool = false,energy = 0):
	#计算轮次提高伤害
	damage = int(damage * round_damage_mul)
	#回复能量
	curr_energy += energy
	curr_energy = clamp(curr_energy,0,max_energy)
	#print(character_name," 造成 ",damage,"点",damage_type_info.get(damage_type,{"name"="未知"})["name"],element_info.get(damage_element,{"name"="未知"})["name"],"伤害，获得",energy,"点能量，","伤害目标为 ",target.character_name)
	#print(character_name," 当前血量为",curr_hp,"，当前能量为",curr_energy)
	#print("————————————————————————————————————————")

#return伤害数值与伤害类型
func damage(count:int,type:String,target,element:String,print:bool = true) -> int:
	#计算一阶伤害
	var first_damage
	if type == "phy":
		first_damage = count*physical_power/target.physical_defense
	elif type == "mag":
		first_damage = count*magical_power/target.magical_defense
	elif type == "real":
		first_damage = count
	else:
		return 0
	#计算二阶伤害,即参与属性克制后的伤害
	var element_multiplier = get_element_multiplier(element, target.element)
	var second_damage = int(first_damage * element_multiplier)
	#计算三阶伤害，原计算增伤与免伤后的伤害，现空置
	var third_damage = second_damage - (target.damage_reduction/100)*second_damage + (damage_improve/100)*second_damage
	#计算四阶伤害，元素反应伤害
	var forth_damage = third_damage
	#融化伤害
	if target.ice_stacks >0 and element == "fire":
		forth_damage = int(third_damage*(1+0.01*(((60+((target.ice_stacks-1)*10))*5.0/3.0))))
	if print:
		print("伤害由",first_damage,"修正至",third_damage,"！")
	return forth_damage

func be_and_to_damage(damage,target,source,damage_type:String,damage_element:String,is_extra:bool = false,target_energy = int(round(damage/100.0)),player_energy = 0):
	#计算增伤与免伤伤害
	var first_damage = damage - (target.damage_reduction/100)*damage + (damage_improve/100)*damage
	#计算轮次提高伤害
	var second_improve_damage = int(first_damage * round_damage_mul);
	
	target.be_damage(second_improve_damage,source,damage_type,damage_element,is_extra,target_energy)
	to_damage(second_improve_damage,target,damage_type,damage_element,is_extra,player_energy)

#获取属性克制倍率
func get_element_multiplier(element,target_element) -> float:
	return element_multiplier.get(element, {}).get(target_element, 0)

#播放功能技能动画与音效
func tool_skill_animation():
	$tool_audio.play()
	var sprite = get_node("Sprite2D")
	var tween = create_tween()
	if Global.playing_animation_time < 1.2:
		Global.playing_animation_time = 1.2
	tween.tween_property(sprite, "scale", Vector2(1,1), 0.3)
	tween.tween_property(sprite, "scale", Vector2(0.6,0.6), 0.3)
	
#播放攻击技能动画与音效
func attack_skill_animation():
	if Global.playing_animation_time < 1.2:
		Global.playing_animation_time = 1.2
	$attack_audio.play()
	var sprite = get_node("Sprite2D")
	var tween = create_tween()
	var sprite_origion_position = sprite.position
	tween.tween_property(sprite, "scale", Vector2(1,1), 0.2)
	if sprite.position.x < 600:
		tween.tween_property(sprite, "position", sprite.position + Vector2(530,0), 0.1)
	if sprite.position.x >= 600:
		tween.tween_property(sprite, "position", sprite.position - Vector2(530,0), 0.1)
	tween.tween_property(sprite, "position", sprite_origion_position, 0.1)
	tween.tween_property(sprite, "scale", Vector2(0.6,0.6), 0.2)

func addlog(text,is_gray = false):
	if not is_gray:
		log.text += "\n"+str(text)
	else:
		log.text += "\n"+"[color=gray]"+str(text)+"[/color]"

func recover(count,source = self):
	var finaly_recover_count = count ##计算其他因素影响后的最终回复量
	curr_hp += finaly_recover_count
	addlog(character_name+" 回复"+str(finaly_recover_count)+"点HP")
	curr_hp = min(curr_hp,max_hp)
	print(character_name+" 回复"+str(finaly_recover_count)+"点HP")

func recover_energy(count,source = self):
	var finaly_recover_count = count ##计算其他因素影响后的最终回复量
	curr_energy += finaly_recover_count
	addlog(character_name+" 回复"+str(finaly_recover_count)+"点能量")
	curr_energy = min(curr_energy,max_energy)
	print(character_name+" 回复"+str(finaly_recover_count)+"点能量")

func remove_energy(count,source = self):
	var finaly_remove_count = count ##计算其他因素影响后的最终回复量
	curr_energy -= finaly_remove_count
	addlog(character_name+" 失去"+str(finaly_remove_count)+"点能量")
	curr_energy = min(curr_energy,max_energy)
	curr_energy = max(curr_energy,0)
	print(character_name+" 失去"+str(finaly_remove_count)+"点能量")


func die():
	is_die = true
	
#入场触发（为触发入场动画时触发）
func enter(enemy,player,enemy_team,player_team):
	print(character_name+"入场函数触发")
	get_node("buff").enter_buff()
	enter_skill(enemy,player,enemy_team,player_team)

func add_shield(count,source = self):
	shield += count
	print(character_name+" 增加了"+str(count)+"点护盾")
	addlog(character_name+" 增加了"+str(count)+"点护盾")

func remove_shield(count,source = self):
	shield -= count
	shield = max(0,shield)
	print(character_name+" 失去了"+str(count)+"点护盾")

#region AI相关
func ai_action(enemy,player,enemy_team,player_team):
	print("ai行动")
	refresh_ai(enemy,player,enemy_team,player_team)
	ai.refresh_enable_skills()
	var skill_choice = ai.choose_skill()
	if not skillc_short_desc:
		attack(enemy,player,enemy_team,player_team)
	else:
		if str(skill_choice) == "change_character":
			get_parent().ai_to_change_character()
		else:
			match skill_choice.id:
				"attack":
					attack(enemy,player,enemy_team,player_team)
				"skilla":
					skilla(enemy,player,enemy_team,player_team)
				"skillb":
					skillb(enemy,player,enemy_team,player_team)
				"skillc":
					skillc(enemy,player,enemy_team,player_team)
				"skilld":
					skilld(enemy,player,enemy_team,player_team)
				_:
					printerr("未找到对应技能函数: ", skill_choice.id)

func refresh_ai(enemy,player,enemy_team,player_team):
	#通用初始化
	ai.curr_energy = curr_energy
	ai.max_energy = max_energy
	ai.curr_hp = curr_hp
	ai.max_hp = max_hp
	ai.enemy = enemy
	ai.player = player
	ai.enemy_team = enemy_team
	ai.player_team = player_team
	ai.skills[1].skill_element = skilla_element
	ai.skills[2].skill_element = skillb_element
	ai.skills[3].skill_element = skillc_element
	ai.skills[4].skill_element = skilld_element
	ai.skills[1].energy_cost = skilla_energy
	ai.skills[2].energy_cost = skillb_energy
	ai.skills[3].energy_cost = skillc_energy
	ai.skills[4].energy_cost = skilld_energy
	add_damage_type(1,skilla_damage_type)
	add_damage_type(2,skillb_damage_type)
	add_damage_type(3,skillc_damage_type)
	add_damage_type(4,skilld_damage_type)
	add_damage_element(1,skilla_element)
	add_damage_element(2,skillb_element)
	add_damage_element(3,skillc_element)
	add_damage_element(4,skilld_element)
	#普攻初始化：
	add_damage_type(0,"phy")
	ai.skills[0].skill_element = element
	add_damage_element(0,element)
	ai.skills[0].energy_cost = 0
	ai.skills[0].damage_count = 100
	ai.skills[0].recover_energy = 5
	
	if get_tree():
		await get_tree().physics_frame
		ai.refresh_enable_skills()
	ai.refresh_enable_skills()

func add_damage_type(skill_index: int, damage_type: String):
	if damage_type not in ai.skills[skill_index].damage_type:
		ai.skills[skill_index].damage_type.append(damage_type)
		
func add_damage_element(skill_index: int, damage_element: String):
	if damage_element not in ai.skills[skill_index].damage_element:
		ai.skills[skill_index].damage_element.append(damage_element)

func remove_damage_element(skill_index: int, damage_element: String):
	if damage_element in ai.skills[skill_index].damage_element:
		ai.skills[skill_index].damage_element.remove(damage_element)

#endregion

func ai_to_continue(enemy,player,enemy_team,player_team):
	if is_ai:
		while enemy.curr_hp <= 0:
			if not get_tree():
				break
			await get_tree().physics_frame
		await get_tree().create_timer(1.18).timeout
		ai_action(enemy,player,enemy_team,player_team)

func has_tag(tag:String) -> bool:
	return tag in tags

#登场时触发的技能，手动在触发时机调用
func enter_skill(enemy,player,enemy_team,player_team):
	pass

#回合开始触发
func phase_begin():
	if not is_curr:
		return;
	if get_tree():
		if get_tree().current_scene.curr_phase == "player":
			if is_ai:
				return
	if get_tree():
		if get_tree().current_scene.curr_phase == "enemy":
			if not is_ai:
				return
	if burning_phase >= 1:
		if element == "water":
			addlog(character_name+" 熄灭了灼烧");
			burning_phase = 0;
			burning_source = null;
		else:
			addlog(character_name+" 受到了灼烧伤害");
			be_and_to_damage(damage(burning_source.magical_power,"mag",self,"fire"),self,burning_source,"mag","fire");
			burning_phase -= 1;
			if burning_phase <= 0:
				addlog(character_name+" 从灼烧中恢复了");
	if parasitism_phase >= 1:
		if element == "fire":
			addlog(character_name+" 烧毁了寄生");
			parasitism_phase = 0;
			parasitism_power = 0;
		else:
			addlog(character_name+" 被汲取了生机");
			if is_ai and get_tree().current_scene:
				be_and_to_damage(damage(parasitism_power,"phy",self,"wood"),self,get_tree().current_scene.player_character_curr,"phy","wood");
				get_tree().current_scene.player_character_curr.recover(damage(parasitism_power,"phy",self,"wood"));
				self.remove_energy(2,get_tree().current_scene.player_character_curr)
				get_tree().current_scene.player_character_curr.recover_energy(2);
			elif not is_ai and get_tree().current_scene:
				be_and_to_damage(damage(parasitism_power,"phy",self,"wood"),self,get_tree().current_scene.enemy_character_curr,"phy","wood");
				get_tree().current_scene.enemy_character_curr.recover(damage(parasitism_power,"phy",self,"wood"));
				self.remove_energy(2,get_tree().current_scene.enemy_character_curr)
				get_tree().current_scene.enemy_character_curr.recover_energy(2);
			parasitism_phase -= 1;
			if parasitism_phase <= 0 :
				addlog(character_name+" 摆脱了寄生");
				parasitism_power = 0;
				parasitism_watered_times = 0;

#寄生函数
func parasitism(phase,source):
	addlog(self.character_name+"被寄生了！")
	parasitism_phase = phase;
	parasitism_power =int(source.physical_power);
	parasitism_watered_times = 0;

#灼烧函数
func burn(phase,source):
	addlog(self.character_name+"被灼烧了！")
	burning_phase = phase;
	burning_source = source;

#睡眠函数
func sleep(is_deep:bool = false):
	if not is_deep:
		if sleep_type>=1:
			return
		addlog(self.character_name+"陷入睡眠")
		sleep_type = 1;
		sleep_probability = 80;
	else:
		if sleep_type>=2:
			return
		addlog(self.character_name+"陷入沉眠！")
		sleep_type = 2;
		sleep_probability = 100;
