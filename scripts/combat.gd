extends RefCounted
## Fixed 50ms logical ticks, independent of rendering/step partitions. At each
## tick: expire, recover, DOT, basic, one eligible ordered skill, enemy, verdict.
const Data = preload("res://scripts/chapter_data.gd")
const STEP = .05
const HZ = 20

static func begin(stats: Dictionary, enemy: Dictionary, constraint: Dictionary = {}) -> Dictionary:
	var e = Data.enemy(enemy)
	var b = {"ticks": 0, "carry": 0.0, "stats": stats.duplicate(true), "enemy": e,
		"constraint": constraint.duplicate(true), "hp": stats.hp, "enemy_hp": e.hp,
		"focus": stats.focus_start, "shield": 0.0, "shield_until": 0,
		"barriers": int(e.barriers) if "warded" in e.traits else 0,
		"cooldowns": {"sword": 0, "flame": 0, "ward": 0, "river": 0},
		"burn": {}, "poison": {}, "next_enemy": ceili(e.interval * HZ),
		"next_burst": int(e.burst_interval * HZ), "next_heal": int(e.heal_interval * HZ),
		"outcome": "", "reason": "", "last_action": "Prepare", "last_enemy_action": "Watching",
		"action_serial": 0, "enemy_serial": 0, "skill_counts": {"sword": 0, "flame": 0, "ward": 0, "river": 0},
		"focus_spent": 0, "cleanses": 0, "bursts": 0, "bursts_blocked": 0, "blocked": 0.0,
		"reflected": 0.0, "barriers_broken": 0, "damage": {"physical": 0.0, "poison": 0.0, "burst": 0.0, "reflection": 0.0}}
	for id in Data.all().skills:
		b.cooldowns[id] = 0
		b.skill_counts[id] = 0
	b.interrupts = 0
	b.focus_refunded = 0
	b.counter_ready = false
	b.counters = 0
	b.law_procs = 0
	resolve(b, true)
	canonical(b)
	return b

static func canonical(b: Dictionary) -> void:
	# A nanounit grid removes decimal JSON parser roundoff before it can
	# alter a later boundary decision. Costs, counters and ticks stay integers.
	for key in ["hp", "enemy_hp", "focus", "shield", "blocked", "reflected"]:
		b[key] = roundf(b[key] * 1000000000.0) / 1000000000.0
	for key in b.damage:
		b.damage[key] = roundf(b.damage[key] * 1000000000.0) / 1000000000.0
	for key in ["burn","poison"]:
		if not b[key].is_empty(): b[key].damage = roundf(b[key].damage*1000000000.0)/1000000000.0
	b.hp = minf(b.hp,b.stats.hp)
	b.enemy_hp = minf(b.enemy_hp,b.enemy.hp)
	b.focus = minf(b.focus,b.stats.focus_cap)

static func advance(b: Dictionary, seconds: float) -> float:
	if seconds <= 0 or not is_finite(seconds) or not b.outcome.is_empty():
		return 0.0
	canonical(b)
	var initial: float = b.carry
	b.carry += seconds
	var steps = 0
	while b.carry + .000000001 >= STEP and b.outcome.is_empty():
		b.carry = maxf(0.0, b.carry - STEP)
		b.ticks += 1
		steps += 1
		resolve(b)
		canonical(b)
	if not b.outcome.is_empty():
		b.carry = 0.0
		return clampf(steps * STEP - initial, 0.0, seconds)
	return seconds

static func protected(b: Dictionary) -> bool:
	return "veiled" in b.enemy.traits and b.ticks % int(b.enemy.phase_period * HZ) < int(b.enemy.phase_length * HZ)

static func enemy_hit(b: Dictionary, raw: float, magic: bool, dot: bool = false) -> void:
	if b.enemy_hp <= 0:
		return
	if b.barriers > 0:
		if not dot:
			b.barriers -= 1
			b.barriers_broken += 1
		return
	var armor: float = maxf(0, b.enemy.armor - b.stats.pierce)
	var resistance: float = minf(.5, b.enemy.resistance + (.35 if protected(b) else 0.0))
	if "alternating" in b.enemy.traits:
		var physical_guard: bool = int(b.ticks / (6*HZ)) % 2 == 0
		if (magic and not physical_guard) or (not magic and physical_guard): raw *= .45
	var amount: float = raw * (1.0 - resistance) if magic else maxf(1.0, (raw - armor) * (.6 if protected(b) else 1.0))
	b.enemy_hp = maxf(0.0, b.enemy_hp - amount)
	if "thorned" in b.enemy.traits and not dot:
		var reflected: float = b.enemy.reflect
		b.reflected += reflected
		player_hit(b, reflected, true, "reflection")

static func player_hit(b: Dictionary, raw: float, magic: bool, source: String) -> void:
	var damage: float = raw * (1.0 - clampf(b.stats.resistance, 0.0, .5)) if magic else maxf(1.0, raw - b.stats.armor)
	if source == "poison":
		damage *= 1.0 - b.stats.dot_reduction
	if source == "burst": damage *= 1.0-b.stats.get("burst_reduction",0.0)
	damage *= b.stats.incoming
	var absorbed = minf(b.shield, damage)
	b.shield -= absorbed
	b.blocked += absorbed
	if source == "burst" and absorbed > 0:
		b.bursts_blocked += 1
		if b.stats.get("law","")=="earth":
			var refund: int = int(Data.all().laws.earth.refund)
			b.focus = minf(b.stats.focus_cap,b.focus+refund)
			b.focus_refunded += refund
			b.law_procs += 1
	damage -= absorbed
	b.damage[source] += damage
	b.hp = maxf(0.0, b.hp - damage)
	# Clear before retaliation. An indirect hit can never start a counter loop.
	if absorbed>0 and source in ["physical","burst"] and b.get("counter_ready",false):
		b.counter_ready = false
		b.counters += 1
		b.last_action = "counter"
		b.action_serial += 1
		enemy_hit(b,Data.all().skills.mirror.retaliation*b.stats.attack*(1+.15*b.stats.mastery.mirror),true,true)

static func eligible(b: Dictionary, id: String) -> bool:
	if not Data.all().skills.has(id):
		return false
	var d: Dictionary = Data.all().skills[id]
	if b.focus + .000000001 < d.focus or b.cooldowns[id] > b.ticks:
		return false
	if b.focus_spent + d.focus > b.constraint.get("focus_budget", 1000000):
		return false
	if id == "ward":
		var charge_due = "channeler" in b.enemy.traits and b.next_burst-b.ticks<=2*HZ
		var needed = charge_due if "channeler" in b.enemy.traits else b.hp<=b.stats.hp*.65
		return b.shield < b.stats.hp * .15 and needed
	if id == "river":
		return not b.poison.is_empty() or b.hp <= b.stats.hp * .8
	if id == "thunder":
		return "channeler" in b.enemy.traits and b.next_burst-b.ticks<=d.window*HZ
	if id == "mirror":
		return b.shield<b.stats.hp*.1 and (b.next_enemy-b.ticks<=HZ or ("channeler" in b.enemy.traits and b.next_burst-b.ticks<=2*HZ))
	return true

static func skill(b: Dictionary, id: String) -> void:
	var d: Dictionary = Data.all().skills[id]
	b.focus = maxf(0, b.focus - d.focus)
	b.focus_spent += int(d.focus)
	b.cooldowns[id] = b.ticks + int(d.cooldown * HZ)
	b.skill_counts[id] += 1
	b.last_action = id
	b.action_serial += 1
	var potency: float = 1.0 + .15 * b.stats.mastery[id]
	match id:
		"sword":
			var burning: bool = not b.burn.is_empty()
			for i in range(2):
				enemy_hit(b, .95 * b.stats.attack * potency * (1.0 + b.stats.sword_bonus), false)
			if burning and b.stats.get("law","")=="fire":
				enemy_hit(b,Data.all().laws.fire.damage*b.stats.attack,true,true)
				b.law_procs += 1
		"flame":
			enemy_hit(b, .6 * b.stats.attack * potency, true)
			var next_tick: int = b.burn.get("next", b.ticks + HZ)
			b.burn = {"next": next_tick, "until": b.ticks + int((4 + b.stats.burn_duration) * HZ), "damage": .4 * b.stats.attack * potency}
		"ward":
			b.shield = maxf(b.shield, .3 * b.stats.hp * potency * (1 + b.stats.shield_bonus))
			b.shield_until = b.ticks + 6 * HZ
		"river":
			if not b.poison.is_empty():
				b.cleanses += 1
				if b.stats.get("law","")=="water":
					b.shield = maxf(b.shield,Data.all().laws.water.shield*b.stats.hp)
					b.shield_until = maxi(b.shield_until,b.ticks+int(Data.all().laws.water.duration*HZ))
					b.law_procs += 1
			b.poison = {}
			b.hp = minf(b.stats.hp, b.hp + .2 * b.stats.hp * potency * (1 + b.stats.healing_bonus))
		"thunder":
			if "channeler" in b.enemy.traits and b.next_burst-b.ticks<=d.window*HZ:
				b.next_burst = b.ticks+int(b.enemy.burst_interval*HZ)
				b.interrupts += 1
			enemy_hit(b,d.damage*b.stats.attack*potency,true)
		"returning":
			var before: int = b.barriers_broken
			for i in range(int(d.hits)): enemy_hit(b,d.damage*b.stats.attack*potency,false)
			if b.barriers_broken>before:
				var refund: int = mini(int(d.refund_cap),int(d.refund)+int(b.stats.get("refund_bonus",0)))
				b.focus = minf(b.stats.focus_cap,b.focus+refund)
				b.focus_refunded += refund
		"mirror":
			b.shield = maxf(b.shield,d.shield*b.stats.hp*potency*(1+b.stats.shield_bonus))
			b.shield_until = b.ticks+int(d.duration*HZ)
			b.counter_ready = true

static func finish(b: Dictionary, won: bool, reason: String) -> void:
	b.outcome = "win" if won else "defeat"
	b.reason = reason

static func resolve(b: Dictionary, initial: bool = false) -> void:
	if not initial:
		if b.ticks >= b.shield_until:
			b.shield = 0.0
			b.counter_ready = false
		b.focus = minf(b.stats.focus_cap, b.focus + b.stats.focus_regen * STEP)
		if not b.burn.is_empty() and b.ticks >= b.burn.next:
			# Tick at expiry is included: 4 seconds means exactly four ticks.
			enemy_hit(b, b.burn.damage, true, true)
			b.burn.next += HZ
			if b.ticks >= b.burn.until:
				b.burn = {}
		if not b.poison.is_empty() and b.ticks >= b.poison.next:
			player_hit(b, b.poison.damage, true, "poison")
			b.poison.next += HZ
			if b.ticks >= b.poison.until:
				b.poison = {}
	if b.hp > 0 and b.enemy_hp > 0:
		if b.ticks % (2 * HZ) == 0 and b.constraint.get("basic", true):
			enemy_hit(b, b.stats.attack, false)
			b.last_action = "strike"
			b.action_serial += 1
		if b.ticks % HZ == 0 and b.enemy_hp > 0 and b.hp > 0:
			for id in b.stats.slots:
				if eligible(b, id):
					skill(b, id)
					break
	if b.enemy_hp > 0 and b.hp > 0:
		if b.ticks >= b.next_enemy:
			player_hit(b, b.enemy.attack, false, "physical")
			b.next_enemy += ceili(b.enemy.interval * HZ)
			b.last_enemy_action = "strike"
			b.enemy_serial += 1
			if "venomous" in b.enemy.traits:
				b.poison = {"next": b.poison.get("next", b.ticks + HZ), "until": b.ticks + int(b.enemy.poison_duration * HZ), "damage": b.enemy.poison}
		if "channeler" in b.enemy.traits and b.ticks >= b.next_burst:
			player_hit(b, b.enemy.attack * b.enemy.burst, false, "burst")
			b.bursts += 1
			b.next_burst += int(b.enemy.burst_interval * HZ)
			b.last_enemy_action = "burst"
			b.enemy_serial += 1
		if "healer" in b.enemy.traits and b.ticks >= b.next_heal:
			b.enemy_hp = minf(b.enemy.hp, b.enemy_hp + b.enemy.hp * b.enemy.heal)
			b.next_heal += int(b.enemy.heal_interval * HZ)
			b.last_enemy_action = "heal"
	if b.hp <= 0:
		var reason = "Incoming damage exceeded your recovery."
		if b.damage.poison > b.damage.physical:
			reason = "Poison overcame your recovery. Try River Confluence or River Silk."
		elif b.damage.reflection > b.damage.physical:
			reason = "Direct hits triggered too much reflection. Flame ticks do not reflect."
		elif b.damage.burst > 0:
			reason = "Burst damage broke through. Try Ward, Iron or armor."
		finish(b, false, reason)
		return
	var objective: String = b.constraint.get("objective", "win")
	if objective == "reflection" and b.reflected > b.constraint.target:
		finish(b, false, "Reflected damage exceeded 30. Use damage over time.")
	elif objective == "survive_cleanse" and b.ticks >= b.constraint.duration * HZ:
		finish(b, b.cleanses >= b.constraint.target, "Cleanse twice and survive 30 seconds.")
	elif objective == "survive_burst" and b.ticks >= b.constraint.duration * HZ:
		finish(b, b.bursts >= 3 and b.bursts_blocked >= 1 and b.hp >= .25 * b.stats.hp, "Endure three bursts, shield at least one and retain 25% HP.")
	elif b.enemy_hp <= 0 and not objective in ["survive_cleanse", "survive_burst"]:
		var success: bool = objective != "barrier" or b.barriers_broken >= b.constraint.target
		var objective_reason = "Break all nine barrier layers."
		if objective=="charge_answer":
			success = b.interrupts+b.bursts_blocked>=1
			objective_reason = "Answer a charged strike: Thunder interrupts; Ward protects."
		elif objective=="combination":
			success = b.skill_counts.flame>0 and b.skill_counts.sword+b.skill_counts.returning>0
			objective_reason = "Combine Flame with Sword or Returning."
		elif objective=="cleanse_win":
			success = b.cleanses>=b.constraint.target
			objective_reason = "Remove poison twice with River before winning."
		elif objective=="healthy_win":
			success = b.hp>=b.stats.hp*b.constraint.minimum_hp
			objective_reason = "Finish with at least 25% HP; River or Mirror helps."
		finish(b, success, "Guardian overcome." if success else objective_reason)
	elif b.ticks >= int(b.constraint.get("limit", 90) * HZ):
		finish(b, false, "Time limit reached. Increase sustained damage or change the skill order.")
