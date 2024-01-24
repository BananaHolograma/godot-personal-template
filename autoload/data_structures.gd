extends Node


## Flatten any array with n dimensions
func flatten(array: Array, result = []):
	for i in array.size():
		if typeof(array[i]) >= TYPE_ARRAY:
			flatten(array[i], result)
		else:
			result.append(array[i])

	return result
