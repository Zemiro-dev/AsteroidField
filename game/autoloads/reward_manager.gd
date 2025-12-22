extends Node
class_name RewardManager


static var level_up_rewards := [
	LevelableStatModifier.ProjectileBonusProjectile,
	LevelableStatModifier.ThrusterModifier,
	LevelableStatModifier.ProjectileAttackSpeedUp,
	LevelableStatModifier.TimeManipulator,
	LevelableStatModifier.FocusingCrystals
]

static func apply_reward(levelable: Levelable, reward: LevelableStatModifier) -> void:
	if reward:
		var modIndex: int = levelable.stat_modifiers.find_custom(
			func(modifier: LevelableStatModifier):
				return reward.code == modifier.code
		)
		if modIndex >= 0:
			levelable.stat_modifiers[modIndex] = reward
		else:
			levelable.stat_modifiers.append(reward)
		levelable.calc_stats()



static func get_possislbe_level_up_rewards(levelable: Levelable, reward_count: int = 3) -> Array[LevelableStatModifier]:
	var possible_rewards: Array[LevelableStatModifier] = []
	for ModifierClass in level_up_rewards:
		var reward := ModifierClass.new() as LevelableStatModifier
		for modifier in levelable.stat_modifiers:
			if reward.code == modifier.code:
				if modifier.strength < modifier.max_strength:
					reward.strength = modifier.strength + 1
				else:
					reward = null
					break
		if reward:
			possible_rewards.append(reward)
	possible_rewards.shuffle()
	return possible_rewards.slice(0, reward_count)
