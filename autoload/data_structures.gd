extends Node


## Remove nullable or false values from an array
func compact(array: Array):
	var new_array := []
	
	for item in array:
		if item:
			new_array.append(item)
			
	return new_array
	
## Creates an array of array values not included in the other given arrays 
## using == for comparisons. The order and references of result values 
## are determined by the first array.
func difference(array_left: Array, array_right: Array): 	
	var new_array := []
	new_array.append_array(array_left)
	
	for array_item_2 in array_right:
		new_array.erase(array_item_2)
		
	return new_array
	
		
## Flatten any array with n dimensions recursively
func flatten(array: Array, result = []):
	for i in array.size():
		if typeof(array[i]) >= TYPE_ARRAY:
			flatten(array[i], result)
		else:
			result.append(array[i])

	return result


func pick_random_values(array: Array, items_to_pick :int = 1, duplicates: bool = true) -> Array:
	var result := []
	var target = flatten(array.duplicate())
	target.shuffle()
	
	items_to_pick = min(target.size(), items_to_pick)
	
	for i in range(items_to_pick):
		var item = target.pick_random()
		result.append(item)

		if not duplicates:
			target.erase(item)
		
	return result

## Reorder the middle on array ignoring the first and last element
## Example sorting by descendant order: [1,2,3,4,5,6] -> [1,5,4,3,2,6]
func reorders_the_middle_of_an_array(array: Array, sort_callback: Callable) -> Array:
	var target = array.duplicate()
	
	if array.size() > 3:
		var first = target.front()
		var last = target.back()
		var sliced = target.slice(1, -1)
		
		sliced.sort_custom(sort_callback)
		
		## We set the new turn queue so we always have a fresh state of the battle flow
		target = [first]
		target.append_array(sliced)
		target.append(last)
	
	return target
	
