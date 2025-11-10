
# Actor List

## Min List

```
Player
Grunt - basic enemy
Hurtbox
AsteroidChunk
Destructible

```




# Technical Game Actor Details

Game Actors are a custom node tree that help contain and maintain the bulk of the custom game actor logic.

Game Actors are meant to be direct children of other Godot native nodes that define the game-y specific logic of those

## Logic of Game Actors

Since godot native nodes are still doing stuff for the game, what do I actually mean by gamey logic?

A game actor should *never* directly alter another game actor or its scene tree. It may only call a method on that game actor to affect change.

- takingDamage - whenever one game actor wants to deal damage to another it should wrap it into a damage message before asking the target to apply it. The target may translate damage. Taking damage may cause aftereffects like death
- handlingInteractions - for physics bodies an interaction is a collision. For area2ds an interaction occurs when another area or physics body enters the area.

## Signals
- on_damage_taken
- on_health_changed
- on_death

## Attributes
These are standard attributes of game actors that other game actors may need to determine their changes in case of damage or interaction



## Structure

- Area2D
	- GameActor
		- :readyStrategy? - use this to translate some stuff into the more typical flow. Such as the signals strategy for area2d vs process siguation for entities?
		- :is_invincible
		- :handleDamage
		- :handleInteraction
			-  
