INS_CAS_pilotTypes = ["B_Pilot_F", "B_helicrew_F"];
INS_CAS_airCraftTypes = ["B_Plane_CAS_01_F", "O_Plane_CAS_02_F", "I_Plane_Fighter_03_CAS_F", "I_Plane_Fighter_03_AA_F"];

INS_CAS_trackAircraft = {
	private ["_plane"];
	_plane = _this;

	_markerName = format ["track%1",random 99999];
	_marker = createMarker[_markerName, [0, 0, 0]];
	_markerName setMarkerType "mil_triangle";
	_markerName setMarkerColor "ColorBLUFOR";

	while { !isNull _plane && alive _plane } do {
		_markerName setMarkerDir (getDir _plane);
		_markerName setMarkerPos (getPos _plane);
		sleep 0.1;
	};

	deleteMarker _marker;
};

INS_CAS_spawnPilot = {
	private ["_pos", "_squadron", "_type", "_pilot"];
	_pos = _this select 0;
	_squadron = createGroup west;
	_type = INS_CAS_pilotTypes call BIS_fnc_selectRandom;

	_pilot = _squadron createUnit ["B_Pilot_F", _pos, [], 0, "FORM"];	

	_squadron setBehaviour "STEALTH";
	_squadron setSpeedMode "FULL";
	_squadron setCombatMode "BLUE";

	_pilot	
};

INS_CAS_spawnAircraft = {
	private ["_type", "_position", "_target", "_vehicle"];
	_type = if ((_this select 0) != "") then { _this select 0 } else { INS_CAS_airCraftTypes call BIS_fnc_selectRandom };
	_position = _this select 1;
	_target = _this select 2;

	_vehicle = createVehicle [_type, [_position select 0, _position select 1, 1000], [], 0, "FLY"];
	_vehicle setVectorDir [(_target select 0) - (getPos _vehicle select 0), (_target select 1) - (getPos _vehicle select 1), 0];
	sleep 0.2;

	_vehicle setVelocity [sin(getDir _vehicle) * 200, cos(getDir _vehicle) * 200, 0];
	_vehicle spawn INS_CAS_trackAircraft;

	_vehicle
};

INS_CAS_initPlane = {
	private ["_plane", "_pilot"];
	_plane = _this select 0;
	_pilot = _this select 1;

	_pilot moveInDriver _plane;
	_plane flyInheight 1000;
};

INS_CAS_notifyETA = {
	private ["_plane", "_targetLoc"];
	_plane = _this select 0;
	_targetLoc = _this select 1;

	_velocity = velocity _plane;
	_deltax = _velocity select 0;
	_deltay = _velocity select 1;

	_speed = sqrt (_deltax * _deltax + _deltay * _deltay);
	(leader group driver _plane) sideChat format ["Cordinates recieved, CAS inbound - %1 seconds out", round (((getPos _plane) distance _targetLoc) / _speed)];	
};

INS_CAS_homeMissile = {
	private ["_velocityX", "_velocityY", "_velocityZ", "_target"];
	_bomb = _this select 0;
	_target = _this select 1;
	_bombSpeed = 100;

	if (_bomb distance _target > (_bombSpeed / 20)) then {
		_travelTime = (_target distance _bomb) / _bombSpeed;

		_relDirHor = [_bomb, _target] call BIS_fnc_DirTo;
		_bomb setDir _relDirHor;

		_relDirVer = asin ((((getPosASL _bomb) select 2) - ((getPosASL _target) select 2)) / (_target distance _bomb));
		_relDirVer = (_relDirVer * -1);
		[_bomb, _relDirVer, 0] call BIS_fnc_setPitchBank;

		_velocityX = (((getPosASL _target) select 0) - ((getPosASL _bomb) select 0)) / _travelTime;
		_velocityY = (((getPosASL _target) select 1) - ((getPosASL _bomb) select 1)) / _travelTime;
		_velocityZ = (((getPosASL _target) select 2) - ((getPosASL _bomb) select 2)) / _travelTime;
	};

	[_velocityX, _velocityY, _velocityZ]
};

INS_CAS_createOrdinance = {
	private ["_velocityZ", "_plane", "_targetLoc", "_isCBU", "_bomb", "_drop", "_target"];
	_plane = _this select 0;
	_targetLoc = _this select 1;
	_type = _this select 2;
	_isCBU = if (count _this > 3) then { true } else { false };

	_target = createAgent ["Logic", [(_targetLoc select 0), (_targetLoc select 1), 0], [] , 0 , "CAN_COLLIDE"];  
	_drop = createAgent ["Logic", [(getPos _plane select 0), (getPos _plane select 1), 0], [] , 0 , "CAN_COLLIDE"]; 
	
	sleep 0.2; 

	_bomb = _type createVehicle [(getPos _drop select 0), (getPos _drop select 1), (225 + (getPosASL _target select 2)) - (getPosASL _drop select 2) + (if (_isCBU) then { 40 } else { 0 })];
	_bomb setDir ((_targetLoc select 0) - (getPos _bomb select 0)) atan2 ((_targetLoc select 1) - (getPos _bomb select 1));

	_bDrop = sqrt(((getPosASL _bomb select 2) - (getPosASL _target select 2)) / 4.9);
	_bVelX = ((_targetLoc select 0) - (getPos _bomb select 0)) / _bDrop;
	_bVelY = ((_targetLoc select 1) - (getPos _bomb select 1)) / _bDrop;
	_bomb setVelocity [_bVelX, _bVelY, (velocity _bomb select 2) - (85 - (if (_bomb distance _targetLoc > 536) then {1} else {-1}) * (abs ((_bomb distance _targetLoc) - 536) * 0.150))];

	deleteVehicle _drop;
	deleteVehicle _target;

	_bomb
};

INS_CAS_doCounterMeasure = {
	private ["_plane"];
	_plane = _this select 0;

	for "_i" from 1 to 4 do { _bool = _plane fireAtTarget [_plane, "CMFlareLauncher"]; sleep 0.3; };
	sleep 3;
	for "_i" from 1 to 4 do { _bool = _plane fireAtTarget [_plane, "CMFlareLauncher"]; sleep 0.3; };
};

INS_CAS_casTimeOut = {
	_timeout = _this select 0;
	timeUntilNextCAS = _timeout;

	while { timeUntilNextCAS > 0 } do {		
		timeUntilNextCAS = timeUntilNextCAS - 1; 
		publicVariable "timeUntilNextCAS";
		sleep 1;
	};
};

INS_CAS_finishCAS = {
	player removeAction INS_cancel_AID;
	call INS_CAS_removeMenuItems;
	INS_CAS_casRequest = false; publicVariable "INS_CAS_casRequest";
	INS_CAS_waitCAS = false; publicVariable "INS_CAS_waitCAS";
	deleteMarker "CAS_TARGET";
	deleteMarker "CAS_ORIG";	
};