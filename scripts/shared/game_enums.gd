extends RefCounted
class_name GameEnums

enum GamePhase {
	LOBBY,
	COUNTDOWN,
	ACTIVE,
	POT_COOKING,
	ESCAPE,
	ROUND_RESULT,
	MATCH_RESULT,
}

enum TeamSide {
	TEAM_A,
	TEAM_B,
}

enum DefenderRole {
	PAPA,
	TROLAZZO,
	BESTIA,
}

enum AttackerPassive {
	TANQUE,
	CAZADOR,
	PORTA_PAPAS,
}

enum PapaState {
	FREE,
	CAPTURED,
	BEING_COOKED,
	COOKED,
}

enum RoundEndReason {
	ESCAPE_SUCCESS,
	ATTACKERS_ELIMINATED,
	TIME_EXPIRED,
	DISCONNECT,
}
