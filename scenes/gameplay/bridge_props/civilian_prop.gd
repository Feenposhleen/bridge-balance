class_name BalanceCivilian
extends BalanceProp

var _props: BalanceProps
var _saved: bool = false
var _died: bool = false

func _ready() -> void:
	super()
	var parent = get_parent()
	if parent is BalancePropCollection:
		parent = parent.get_parent()
		
	_props = parent

func _physics_process(delta: float) -> void:
	super(delta)
	
	if _saved || _died: return
	
	var colliders = _props.check_prop_collision(position_2d)
	for collider in colliders:
		if collider is BalancePlayer:
			_saved = true
			GameState.civilian_saved.emit(self)
			prop_exit.emit(self)
		elif collider.friction < 0.99:
			_died = true
			GameState.civilian_died.emit(self)
			prop_exit.emit(self)
			
		
