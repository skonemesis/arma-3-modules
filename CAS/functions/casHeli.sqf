if (INS_CAS_waitCAS) exitWith { hintSilent "CAS already enroute, cancel current CAS or wait for CAS execution before next request!" };
INS_CAS_waitCAS = true; publicVariable "INS_CAS_waitCAS";

_targetLoc = getMarkerPos "CAS_TARGET";
_originLoc = getMarkerPos "CAS_ORIG";

INS_cancel_AID = player addAction ["Done CAS", "INS_CAS_abortCAS = true;"];

_helo = ["B_Heli_Attack_01_F", _originLoc, _targetLoc] call INS_CAS_spawnAircraft;
_pilot = [_originLoc] call INS_CAS_spawnPilot;
[_helo, _pilot] call INS_CAS_initPlane;

//_gunner = [_originLoc] call INS_CAS_spawnPilot;
_originalPosition = getPosASL player;
player moveInGunner _helo;
/*
_op = player;
selectPlayer _gunner;

INS_cancel_AID = _gunner addAction ["Done CAS", "INS_CAS_abortCAS = true;"];*/

(driver _helo) doMove _targetLoc;
_wp = group _helo addWaypoint [_targetLoc, 1];
_wp setWaypointType "LOITER";

// move player into gunner

waitUntil { _helo distance _targetLoc < 900 or INS_CAS_abortCAS or !alive _helo };

_timeSlept = 0;
while { !INS_CAS_abortCAS && alive _helo } do {
	sleep 1;
	_timeSlept = _timeSlept + 1;

	if (_timeSlept > casPlayerTimeLimit) then { INS_CAS_abortCAS = true; call INS_CAS_finishCAS; } 
	else { hint parseText format["<t color='#6775cf'>%1</t> seconds left", (casPlayerTimeLimit - _timeSlept)]; };
};

_wp setWaypointPosition [getPos _helo, 3];
deleteWaypoint _wp;

player setPosASL _originalPosition;
//selectPlayer _op;
call INS_CAS_finishCAS;

(driver _helo) doMove _originLoc;
waitUntil{ _helo distance _targetLoc >= 2000 || !alive _helo };

{
	deleteVehicle vehicle _x;
	deleteVehicle _x;
} forEach units group _helo;