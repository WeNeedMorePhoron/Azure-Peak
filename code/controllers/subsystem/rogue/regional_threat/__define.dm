/// Multiplier for base_divisor to determine the "safe" floor for a region.
/// Below (base_divisor * this), natural ambushes stop firing. Signal horn can still go below.
/// With base_divisor 5: floor = 25 TP. Wardens can clear a region down to this threshold.
#define AMBUSH_SAFE_FLOOR_MULTIPLIER 5

/// Display thresholds — percentage of max_ambush for each danger level label.
#define DANGER_PCT_SAFE 15    // 0% to this = Safe (green)
#define DANGER_PCT_LOW 35     // to this = Low (yellow)
#define DANGER_PCT_MODERATE 55 // to this = Moderate (orange)
#define DANGER_PCT_DANGEROUS 80 // to this = Dangerous (red), above = Bleak (purple)

/// Tick rate multipliers — fraction of max_ambush added per SS tick.
/// SS fires every 30 minutes = 6 ticks per 3-hour round.
/// Highpop: 20% of max per tick → full refill in 5 ticks (2.5 hours).
/// Lowpop: 10% of max per tick → full refill in 10 ticks (5 hours).
#define THREAT_HIGHPOP_TICK_RATE 0.2
#define THREAT_LOWPOP_TICK_RATE 0.1
