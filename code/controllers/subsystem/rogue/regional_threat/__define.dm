#define DANGER_SAFE_FLOOR 0
#define DANGER_SAFE_LIMIT 10
#define DANGER_LOW_FLOOR 11
#define DANGER_LOW_LIMIT 20
#define DANGER_MODERATE_FLOOR 21
#define DANGER_MODERATE_LIMIT 30
#define DANGER_DANGEROUS_FLOOR 31
#define DANGER_DANGEROUS_LIMIT 40
#define DANGER_BLEAK_FLOOR 41
#define DANGER_BLEAK_LIMIT 60

/// Multiplier for base_divisor to determine the "safe" floor for a region.
/// Below (base_divisor * this), natural ambushes stop firing. Signal horn can still go below.
/// With base_divisor 5: floor = 25 TP. Wardens can clear a region down to this threshold.
#define AMBUSH_SAFE_FLOOR_MULTIPLIER 5
