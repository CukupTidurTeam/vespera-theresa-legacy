extends Node
 
## CONSTANTS - Autoload singleton (Project Settings > Autoload)
## Kumpulan string constants supaya tidak ada "magic string" tersebar
## di banyak file. Kalau nanti mau rename group/anim, cukup ubah di sini.

# --- Groups ---
const GROUP_PLAYER := "player"
const GROUP_ENEMY := "enemy"
 
# --- Animation names (harus sama persis dengan nama di SpriteFrames) ---
const ANIM_IDLE := "idle"
const ANIM_RUN := "run"
const ANIM_JUMP := "jump"
const ANIM_DEATH := "death"
const ANIM_ATTACK_LIGHT := "attack_light"
const ANIM_ATTACK_DARK := "attack_dark"
const ANIM_ATTACK := "attack"
const ANIM_HURT := "hurt"
 
# --- Attribute types (dipakai di combat, damage system nanti) ---
enum AttributeType { LIGHT, DARK }
 
# --- Attack direction (dipakai Player & bisa dipakai Enemy nanti) ---
enum AttackDirection { RIGHT, LEFT, UP, DOWN }
 
