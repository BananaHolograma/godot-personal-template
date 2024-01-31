extends Node

### PLAYER ###
signal lock_player
signal unlock_player

### INTERACTIONS ###
signal interacted(interactable: Interactable)
signal cancel_interact(interactable: Interactable)
signal focused(interactable: Interactable)
signal unfocused(interactable: Interactable)

### UI ###
signal show_pause_menu

### SAVE & LOAD ###
signal deleted_saved_game(filename: String)
