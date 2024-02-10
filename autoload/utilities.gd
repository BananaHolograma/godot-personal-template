extends Node

signal frame_freezed

@onready var random_number_generator: RandomNumberGenerator = RandomNumberGenerator.new()

func frame_freeze(time_scale: float, duration: float):
	frame_freezed.emit()
	
	var original_value: float = Engine.time_scale
	
	Engine.time_scale = time_scale
	await get_tree().create_timer(duration * time_scale).timeout
	Engine.time_scale = original_value


func generate_random_string(length: int, characters: String =  "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"):
	var result = ""
	
	if not characters.is_empty() and length > 0:
		for i in range(length):
			result += characters[random_number_generator.randi() % characters.length()]

	return result

func is_valid_url(url: String) -> bool:
	var regex = RegEx.new()
	var url_pattern = "/(https:\\/\\/www\\.|http:\\/\\/www\\.|https:\\/\\/|http:\\/\\/)?[a-zA-Z]{2,}(\\.[a-zA-Z]{2,})(\\.[a-zA-Z]{2,})?\\/[a-zA-Z0-9]{2,}|((https:\\/\\/www\\.|http:\\/\\/www\\.|https:\\/\\/|http:\\/\\/)?[a-zA-Z]{2,}(\\.[a-zA-Z]{2,})(\\.[a-zA-Z]{2,})?)|(https:\\/\\/www\\.|http:\\/\\/www\\.|https:\\/\\/|http:\\/\\/)?[a-zA-Z0-9]{2,}\\.[a-zA-Z0-9]{2,}\\.[a-zA-Z0-9]{2,}(\\.[a-zA-Z0-9]{2,})?/g"
	regex.compile(url_pattern)
	
	return regex.search(url) != null


func open_external_link(url: String):
	if is_valid_url(url) and OS.has_method("shell_open"):
		if OS.get_name() == "Web":
			url = url.uri_encode()
			
		OS.shell_open(url)


func _format_seconds(time : float, use_milliseconds : bool) -> String:
	var minutes := time / 60
	var seconds := fmod(time, 60)
	
	if not use_milliseconds:
		return "%02d:%02d" % [minutes, seconds]
		
	var milliseconds := fmod(time, 1) * 100
	
	return "%02d:%02d:%02d" % [minutes, seconds, milliseconds]


## This function calculates the sigmoid or logistic function, commonly used in game development for various purposes
## such as character behavior modeling, AI decision-making, and game mechanics design. 
##In the context of game development, the sigmoid function is often employed to map input values to output probabilities or to create smooth transitions between states or actions. 
##It takes a float input value 'x' and returns a float value between 0 and 1, representing the output of the sigmoid function applied to 'x'.
func sigmoid(x: float) -> float:
	return 1 / (1 + exp(-x))