class_name Cache
extends Reference

var max_entries := 100
var _data := {}


func store_item(key: String, value):
	_data[key] = value


func has_item(key: String):
	return _data.has(key)


func get_item(key: String):
	return _data[key]
