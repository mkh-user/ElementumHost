extends CanvasLayer
#extends CanvasLayer

@export var target: Node
@export var output: Label
@export var use_custom_output: bool = false

var _label: Label

func _ready() -> void:
    _label = Label.new()
    add_child(_label)
    if use_custom_output and output:
            _label = output
    if !target:
        target = self

func _process(_delta: float) -> void:
    output.text = "%d, %d" % [target.global_position.x, target.global_position.y]
