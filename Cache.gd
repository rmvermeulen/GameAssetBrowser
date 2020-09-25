class_name Cache
extends Reference

const MAX_ID: int = 999
var max_entries := 100
var _data := {}
var _next_id: int = 0


func store_item(key: String, item: Array):
	_data[key] = {"id": _next_id, "item": item}
	_next_id = (_next_id + 1) % MAX_ID
	print_debug('added %d entries' % item.size())
	# remove old items
	while _count() > max_entries:
		_remove_oldest()
		print_debug('cache removed key')
	# report
	print_debug('cache size', _count())


func has_item(key: String):
	return _data.has(key)


func get_item(key: String):
	assert(has_item(key))
	return _data[key].item


func _count() -> int:
	var total := 0
	for key in _data:
		total += _data[key].item.size()
	return total


func _remove_oldest():
	if _data.empty():
		return
	var remove_key: String = ""
	var lowest: int = MAX_ID
	for key in _data:
		var entry = _data[key]
		if entry.id > lowest:
			continue
		remove_key = key
		lowest = entry.id
	return _data.erase(remove_key)
