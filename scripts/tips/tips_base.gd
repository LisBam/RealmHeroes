extends Control
class_name tips

@export var need_time_to_hovering:float = 0.5 ##鼠标所需悬停时间
var time_to_hovering:float = 0.0 ##鼠标已累计悬停时间
var is_hovering:bool = false

func _ready() -> void:
	$VBoxContainer/PanelContainer/MarginContainer/RichTextLabel.text = "	"+"这段话是一个[color=red]基类[/color]这段话。"

func _mouse_entered() -> void:
	_ready()
	time_to_hovering = 0.0
	is_hovering = true

func _mouse_exited() -> void:
	_ready()
	$VBoxContainer.visible = false
	time_to_hovering = 0.0
	is_hovering = false
	
func _pressed():
	time_to_hovering -= 999
	$VBoxContainer.visible = false
	
func _process(delta: float) -> void:
	# 如果正在悬停，累计时间
	if is_hovering:
		time_to_hovering += delta
	# 当累计时间达到所需时间且提示框未显示时，显示提示框
	if time_to_hovering >= need_time_to_hovering and not $VBoxContainer.visible:
		$VBoxContainer.visible = true
