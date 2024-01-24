extends Node

@onready var random_number_generator: RandomNumberGenerator = RandomNumberGenerator.new()

## Generate 'n' random directions on the angle range provided
## from an origin vector that will be rotated accordingly
# [Important] The angles needs to be on degrees
#
## [codeblock]
##	Globals2D.generate_random_directions_on_angle_range(Vector2.ZERO, -45, 45, 5)
## [/codeblock]
##
func generate_random_directions_on_angle_range(origin: Vector2 = Vector2.UP, min_angle_range: float = 0.0, max_angle_range: float = 360.0, num_directions: int = 10) -> Array[Vector2]:
	var random_directions: Array[Vector2] = []
	random_directions.resize(num_directions) # Improve performance if we know the final size
	
	var min_angle_range_in_rad = deg_to_rad(min_angle_range)
	var max_angle_range_in_rad = deg_to_rad(max_angle_range)
	
	for i in range(num_directions):
		var random_angle = generate_random_angle(min_angle_range_in_rad, max_angle_range_in_rad)
		random_directions.append(origin.rotated(random_angle))
		
	return random_directions

## Generate a random angle between a provided range
func generate_random_angle(min_angle_range: float = 0.0, max_angle_range: float = 360.0) -> float:
	return lerp(min_angle_range, max_angle_range, randf())


func generate_random_direction() -> Vector2:
	return Vector2(random_number_generator.randi_range(-1, 1), random_number_generator.randi_range(-1, 1)).normalized()


func translate_x_axis_to_vector(axis: float) -> Vector2:
	var horizontal_direction = Vector2.ZERO
	
	match axis:
		-1.0:
			horizontal_direction = Vector2.LEFT 
		1.0:
			horizontal_direction = Vector2.RIGHT
			
	return horizontal_direction


func normalize_vector(value: Vector2) -> Vector2:
		var direction := normalize_diagonal_vector(value)
		
		if direction.is_equal_approx(value):
			return value if value.is_normalized() else value.normalized()
		
		return direction


func normalize_diagonal_vector(direction: Vector2) -> Vector2:
	if is_diagonal_direction(direction):
		return direction * sqrt(2)
	
	return direction


func is_diagonal_direction(direction: Vector2) -> bool:
	return direction.x != 0 and direction.y != 0
	
## Also known as the "city distance" or "L1 distance".
## It measures the distance between two points as the sum of the absolute differences of their coordinates in each dimension.
## 
func distance_manhattan_v2(a: Vector2, b: Vector2) -> float:
	return abs(a.x - b.x) + abs(a.y - b.y)

## Also known as the "chess distance" or "L∞ distance".
## It measures the distance between two points as the greater of the absolute differences of their coordinates in each dimension
func distance_chebyshev_v2(a: Vector2, b: Vector2) -> float:
	return max(abs(a.x - b.x), abs(a.y - b.y))


func length_manhattan_v2(a : Vector2) -> float:
	return abs(a.x) + abs(a.y)


func length_chebyshev_v2(a : Vector2) -> float:
	return max(abs(a.x), abs(a.y))

## This function calculates the closest point on a line segment (defined by two points, a and b) to a third point c. 
## It also clamps the result to ensure that the closest point lies within the line segment.
func closest_point_on_line_clamped_v2(a: Vector2, b: Vector2, c: Vector2) -> Vector2:
	b = (b - a).normalized()
	c = c - a
	return a + b * clamp(c.dot(b), 0.0, 1.0)

## This function is similar to the previous one but does not clamp the result. 
## It calculates the closest point on the line segment defined by a and b to a third point c.
## It uses the same vector operations as the previous closest_point_on_line_clamped_v2 function.
func closest_point_on_line_v2(a: Vector2, b: Vector2, c: Vector2) -> Vector2:
	b = (b - a).normalized()
	c = c - a
	
	return a + b * (c.dot(b))

## 
# Vector3 versions of the above calculation functions
##
func distance_manhattan_v3(a: Vector3, b: Vector3) -> float:
	return abs(a.x - b.x) + abs(a.y - b.y) + abs(a.z - b.z)


func distance_chebyshev_v3(a: Vector3, b: Vector3) -> float:
	return max(abs(a.x - b.x), max(abs(a.y - b.y), abs(a.z - b.z)))


func length_manhattan_v3(a: Vector3) -> float:
	return abs(a.x) + abs(a.y) + abs(a.z)


func length_chebyshev_v3(a: Vector3) -> float:
	return max(abs(a.x), max(abs(a.y), abs(a.z)))


func closest_point_on_line_v3(a: Vector3, b: Vector3, c: Vector3) -> Vector3:
	b = (b - a).normalized()
	c = c - a
	return a + b * (c.dot(b))


func closest_point_on_line_clamped_v3(a: Vector3, b: Vector3, c: Vector3) -> Vector3:
	b = (b - a).normalized()
	c = c - a
	return a + b * clamp(c.dot(b), 0.0, 1.0)


func closest_point_on_line_normalized_v3(a: Vector3, b: Vector3, c: Vector3) -> float:
	b = b - a
	c = c - a
	return c.dot(b.normalized()) / b.length()
