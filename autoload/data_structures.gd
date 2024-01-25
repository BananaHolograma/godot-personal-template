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
