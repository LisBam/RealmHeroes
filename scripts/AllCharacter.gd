extends Node

#定义所有路径

#region PVZ2
#植物
const pvz2_wandousheshou = "res://scenes/character/pvz2_wandousheshou.tscn"
const pvz2_xiangrikui = "res://scenes/character/pvz2_xiangrikui.tscn"
const pvz2_jianguo = "res://scenes/character/pvz2_jianguo.tscn"
const pvz2_huobaolajiao = "res://scenes/character/pvz2_huobaolajiao.tscn"
#僵尸
const pvz2_tutongjiangshi = "res://scenes/character/pvz2_putongjiangshi.tscn"
const pvz2_dubaojiangshi = "res://scenes/character/pvz2_dubaojiangshi.tscn"
const pvz2_fuqianjiangshi = "res://scenes/character/pvz2_fuqianjiangshi.tscn"
#endregion

#可随机到的角色场景路径
var can_random_character = [
	pvz2_wandousheshou,
	pvz2_xiangrikui,
	pvz2_jianguo,
	pvz2_huobaolajiao,
	pvz2_tutongjiangshi,
	pvz2_dubaojiangshi,
	pvz2_fuqianjiangshi,
]

#获取随机一个角色的场景路径
func get_random_character():
	var random_index = randi_range(0,can_random_character.size()-1)
	return can_random_character[random_index]
