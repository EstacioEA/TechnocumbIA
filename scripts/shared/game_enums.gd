extends RefCounted
class_name GameEnums

## Valores de contrato serializados como enteros. Mantenerlos estables entre versiones.
enum GamePhase {
	LOBBY = 0,
	COUNTDOWN = 1,
	ACTIVE = 2,
	POT_COOKING = 3,
	ESCAPE = 4,
	ROUND_RESULT = 5,
	MATCH_RESULT = 6,
}

enum TeamSide {
	TEAM_A = 0,
	TEAM_B = 1,
}

enum DefenderRole {
	PAPA = 0,
	TROLAZZO = 1,
	BESTIA = 2,
}

enum AttackerPassive {
	TANQUE = 0,
	CAZADOR = 1,
	PORTA_PAPAS = 2,
}

enum PapaState {
	FREE = 0,
	CAPTURED = 1,
	BEING_COOKED = 2,
	COOKED = 3,
}

enum RoundEndReason {
	ESCAPE_SUCCESS = 0,
	ATTACKERS_ELIMINATED = 1,
	TIME_EXPIRED = 2,
	DISCONNECT = 3,
}
