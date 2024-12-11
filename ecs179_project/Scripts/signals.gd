class_name Signals
extends Node

signal entered_new_layer(layer: int, old_layer: int)
signal take_damage(damage: int, type: String)
signal collect_soul(ammount: int)
signal player_take_damage(damage: int)
signal player_stunned(timer: Timer, time: float)
