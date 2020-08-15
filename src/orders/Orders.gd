extends Node2D

class_name Orders

signal order_received(type, variant)
signal order_fulfilled(type, ingredients)

export (Array, PackedScene) var order_types
export (int) var order_spawn_time_seconds
export (int) var order_expiry_time_seconds
export (PackedScene) var inventory

var active_orders = []

const ORDER_WIDTH = 300

func _ready():
	assert(order_types != null and len(order_types) > 0)
	assert(order_spawn_time_seconds != null and order_spawn_time_seconds > 0)
	assert(order_expiry_time_seconds != null and order_expiry_time_seconds > 0)
	
	var spawn_order_timer := $SpawnOrderTimer
	spawn_order_timer.wait_time = order_spawn_time_seconds
	var i = active_orders.size()
	spawn_order_timer.connect("timeout", self, "_spawn_order")


func _spawn_order():
	var i = len(active_orders)
	var order: BaseOrder = order_types[0].instance()
	order.position = Vector2(1080, 0)
	order.target_position = Vector2(i * ORDER_WIDTH, 0)
	order.expiry_seconds = order_expiry_time_seconds
	order.inventory = inventory
	
	add_child(order)
	active_orders.append(order)
	
	order.connect("order_fulfilled", self, "_on_order_fulfilled")
	order.connect("order_expired", self, "_on_order_expired")


func _layout():
	for i in active_orders.size():
		var order: BaseOrder = active_orders[i]
		order.target_position = Vector2(i * ORDER_WIDTH, 0)
		order.move_to_target_position()


func on_inventory_updated(ingredients: Dictionary) -> void:
	for order in active_orders:
		if order == null:
			return
		order.on_inventory_updated(ingredients)


func _on_order_fulfilled(order: BaseOrder, items: Dictionary):
	emit_signal("order_fulfilled", order, items)
	active_orders.erase(order)
	_layout()


func _on_order_expired(order):
	var order_to_remove = active_orders.find(order)
	if order_to_remove < 0:
		return
	active_orders.remove(order_to_remove)
	
	_layout()
