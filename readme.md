
# Asteroid Field

This is a small short game challenge. It is meant to be a survivors style game presented in a 2d top down style. The player character is a drone traversing an alien asteroid field. The enemies, players, and terrain are all simple line art.

## Player Character

The player character is a simple transport drone. They will automatically attack nearby enemies. They will scale over the course of a game, but by default start with a slowish speed and a short dash with a medium cooldown.

## Gameplay

The player is tasked with traversing an asteroid field from left to right. The field has various terrain and points of interest that prevent a straight line of travel, Enemies harass the player constantly. The field will have *beacons* that regulate the spawn rate of the alien swarm. The player will always have a UI indicator for the direction of the next *beacon*. If they stray beyond the safe range of a beacon they they be assaulted by an exponentially increasing number of enemies.

Killing enemies provides XP which provides the majority of state upgrades to the player.

At the end of the stage is a boss beyond which is the dropoff point which is game win. If the player is damaged by enemies to the point of death they lose.

## UI

## Player Health
The players health is displayed via a health bar/animated element.

### Navigation
The player's main goal is getting from beacon to beacon. They are aided by a small navigation widget positioned near the viewport edge point that is on the line between the player and the beacon always. It does **not** help the player navigate around obstacles. It will point straight through a wall the player cannot pass through.

The UI element will have a 'filling' animation that indicates the player's distance to the beacon relative to the max safety range. If the element 'empties' entirely the player is in danger.

### Swarm Rage/Attention/Spawn Rate
The swarms spawn rate should be telegraphed to the player somehow. Even if it's just a danger meter that goes up over time.


### Build
Some details of the player's build should be visible on the UI at all times especially the player's level

## Beacons

The player's main goal is simply to go from beacon to beacon. Once a player gets near a beacon it will begin the 'beacon swap procedure'. During this time the player must stay near the beacon and the

## Entities
Entities are players, enemies, and anything the player can destroy-- though they may just be enemies in the code.




## Terrain
- Asteroids: Blocks travel. Come in various sizes and grades. Moving enemies should be able to pass straight through most enemies. Small ones should be destroyed. When an enemy sliders under a medium or large asteroid it should play a particle animation to obscure what's happening like they're 'digging in' to the rock.

## Map Point of Interest (PoI)

These are the fun little dopamine hits spread out through the map. They should be scattered along the path between beacons to encourage players to find the fun.

- Large Asteroids: These are extra large asteroid sprites that take up multiple screen lengths. They should have concave areas with rewards and dead ends. 
	- Secret Paths: Large Asteroids can have covered tunnels that uncover when the enemy covering them is killed
- Mineral Rich Asteroids: When destroyed releases healing or xp.
- Alien Relic: Opens after damage/player hangs nearby TBD. Provides item upgrades 
## Weapons
- Minigun: Fires high speed tiny projectiles. Encourages rate of fire, flat damage, ricochet, and flat damage increases.
- Missile: Fires slow moving homing explosives. Encourages aftereffect, % size, projectile count
- Lightning Aura: Fires small bolts of lighting from the ship periodically that chain. Encourages rate of fire or projectile count. Has built in chain aftereffect that reduces the aftereffect chance for each further projectile. Targets the furthest enemy it can and does damage to any enemies between.
- Laser: Builds up damage over time then overheats. Encourages % size, rate of fire. This might be a secret weapon

## Stats & Upgrades

The stats are a big part of the game play loop as each level the player is given a few choices and 
these stats help define different builds. Each weapon has core stats that define their behavior and abilities. Those are modified by player stats on top that come from upgrades or level ups 

### Weapon Stat Details
#### Weapon Life Cycle

Once acquired a weapon is equipped and deployed. It will be inactive until its activation condition is met (usually an enemy in range). At that point it will first a *burst* of projectiles. A burst is fired one projectile at a time based on the *rate of fire*. A burst is completed once the weapon's *burst count* is satisfied. After which the weapon enters a cooldown period. If it is still active after the cooldown period it fires another *burst*.

RoF can effect cooldown or rate of fire depending on weapon

#### Weapon Stats
		``
- Damage: Damage done by a weapon's hurtbox or aftereffects
- Burst Count: The number of projectiles fired per weapon burst
- Cooldown Duration: The length of this weapon's cooldown period
- Activation Range: Range required before this weapon fire's a burst
- Projectile Speed: The speed a projectile travels
- Projectile Homing Power: The homing strength of a projectile, how well it tracks.
- Projectile Lifespan: How long the projectile survives before fading.
- 

### Stat List

Health Points: If these hit 0 you're dead.
Projectile Count: The number of projectiles that are fired each burst.
Cooldown Reduction: 


### Aftereffects

Aftereffects are a weapons 'leave the battlefield' effect. A missile's aftereffect is its explosion. The projectile itself does very little damage.

## Enemies

Enemies provide the majority of the player xp.

Enemies come in 3 basic forms.

1- Charger. Constantly chases the player and attempts to collide with them.
2- Elite- Can fire a single projectile type or deploy a single telegraph.
3- Boss- Can fire multiple projectile types and/or deploy multiple telegraphs. Has boss title and boss health bar ui.

## How do weapons and effects work?

origin; hardpoint on parent scene/spawner, maybe one day shape based clicky clack?

## Projectile

A projectile is an Area2d that traverses the game world. It is expected to free itself shortly after reaching its destination or if does not reach its destination within a timeout. Generally a projectile will contain nodes the projectile will check for depletion before freeing. In some cases it may activate those nodes upon contact.

The Projectile scene should handle the shared logic for the Sprite, traversal logic (wrappers), depletion strategy and may carry a hurtbox.

## Telegraph
A telegraph is an animated sprit that indicates the area of an upcoming effect. Then at the end of that animation spawns the effect.
## Spawner

The spawner should be a simple something I can reuse.  It should take a Scene that it will instantiate potentially repeatedly. It can be configured to include max amount, current amount, spawn rate, etc.

Problem: When I spawn I will need to configure the scene with who knows what amount of initial parameters. Do I just define ability configuration as one thing and make it an ability spawner? But isn't the player just a spawner with count one? What does a spawner do when it runs out? Is that another configuration?

For now the spawner can just take a SpawnStrategy that has a base type that returns... maybe a ref 2d? And the SpawnStrategy is what is passed to the spawner. The strategy can have typed attributes that can be updated via the actor entities process code. When the spawner needs to spawn it can call the spawn strategy which takes over from there. The spawner only expects a SpawnAttemptResponse from the SpawnStrategy which is... tbd but probably true or false. at least.

### Features
- Has way to manually spawn that maybe ignored everything? Or queue for next spawn? Figure out what I need before implementing
- Delay timer stuff allows spawner to be fire and forget

### Attributes
- SpawnStrategy
- SpawnDelay: timer?
- Active
- MaxSpawnCount
- RemainingSpawnCount
### Scene Tree

Node2d
- Sprite: Static sprite for the spawner. 
- AnimationPlayer: activate, deactivate, death, spawn
- Marker2d: spawn point

### Signals
onSpawn->SpawnedEntity, have method do if entity is TheTypeTheyCareAbout

## Hurtboxes

Hurtboxes are expected to be short lived.  They do damage on collision and expect to be freed or deactivated depending on usage.

### Attributes
- damage: how much damage the hurtbox does when an entity enters it
### Signals
- onDamageDealt

# Things to make

## UI
- Health Bar
- Beacon Nav
- Boss Name and Health Bar
- Item Selection
- Weapon Selection
- Screen Edge Damage
- Start Screen
- Pause Screen
- Death Screen
- Win Screen
- Beacon Reduced Range Indicator
- Alien Relic Range Indicator
- 
## Driven Entities
- Player
- Charge Enemy
- Medium Enemy
- Boss Enemey
- Tunnel Blocker Enemy

## World
- Asteroids
	- Tiny
	- Small
	- Medium
	- Large
	- Tunnel Background
- Alient Relic
- Beacon
- Drop Off Station

## Projectiles
- Bullet
- Missile
- Lightning
- Laser

## Telegraph
- Protean
- Circle

## Effects
- Missile Explosion
- Enemy Tunneling
- Bullet Trail
- Lightning
- 

## Sounds
