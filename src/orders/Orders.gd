tool
extends Node2D

class_name Orders

signal order_received(type, variant)
signal order_fulfilled(type, ingredients)

export (Array, PackedScene) var order_types
export (int) var order_spawn_time_seconds

var inventory
var active_orders = []
var state = states.ACTIVE

const ORDER_WIDTH = 300

enum states {
	ACTIVE,
	GAMEOVER,
}


func _ready():
	assert(order_types != null and len(order_types) > 0)
	assert(order_spawn_time_seconds != null and order_spawn_time_seconds > 0)
	
	var spawn_order_timer := $SpawnOrderTimer
	spawn_order_timer.wait_time = order_spawn_time_seconds
	var i = active_orders.size()
	spawn_order_timer.connect("timeout", self, "_spawn_order")


func _spawn_order():
	var i = len(active_orders)
	var order: BaseOrder = order_types[0].instance()
	order.position = Vector2(1080, 0)
	order.target_position = Vector2(i * ORDER_WIDTH, 0)
	order.inventory = inventory
	
	add_child(order)
	active_orders.append(order)
	
	order.connect("order_fulfilled", self, "_on_order_fulfilled")
	order.connect("order_expired", self, "_on_order_expired")


func _layout():
	if state == states.GAMEOVER:
		return
	
	for i in active_orders.size():
		var order: BaseOrder = active_orders[i]
		order.target_position = Vector2(i * ORDER_WIDTH, 0)
		order.move_to_target_position()


func on_inventory_updated(ingredients: Dictionary) -> void:
	if state == states.GAMEOVER:
		return
	
	for order in active_orders:
		if order == null:
			return
		order.on_inventory_updated(ingredients)


func _on_order_fulfilled(order: BaseOrder, items: Dictionary):
	if state == states.GAMEOVER:
		return
	
	emit_signal("order_fulfilled", order, items)
	active_orders.erase(order)
	_layout()


func _on_order_expired(order):
	if state == states.GAMEOVER:
		return
	
	var order_to_remove = active_orders.find(order)
	if order_to_remove < 0:
		return
	active_orders.remove(order_to_remove)
	
	_layout()


func _on_gameover():
	state = states.GAMEOVER
	
	var spawn_order_timer := $SpawnOrderTimer
	spawn_order_timer.stop()
	spawn_order_timer.disconnect("timeout", self, "_spawn_order")
	
	for order in active_orders:
		order.disconnect("order_fulfilled", self, "_on_order_fulfilled")
		order.disconnect("order_expired", self, "_on_order_expired")
		order.on_game_over()
