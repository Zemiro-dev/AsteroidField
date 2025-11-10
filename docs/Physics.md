# Layers
1- Environment
2- Player
3- Enemy
4- Props
### Collisions
- Player vs. Enemy: All enemies cause collision damage to the player along with provide some amount of knockback force to the player.
- Player vs. Asteroid: Small damage to the player and small amount of knockback power. Immediate speed reduction
- Enemy vs. Asteroid: Enemies can go inside asteroids. But I'll have to do something with z-index so they sit right on the screen on top of telegraphs when they aren't behind asteroids