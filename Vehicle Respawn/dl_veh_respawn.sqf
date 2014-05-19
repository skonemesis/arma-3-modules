/*  dl_veh_respawn.sqf
 *	usage: add:
 *		   [this, NAME_OF_VEHICLE, DESTROYED_RESPAWN_DELAY, ABANDONED_RESPAWN_DELAY, INIT (STRING)] execVM "dl_veh_respawn.sqf";
 *		   to each vehicle you wish to be respawnable.
 *
 *		   add:
 * 		   [] execVM "dl_veh_respawn.sqf";
 * 		   to your init.sqf
 *
 *	if destroyed, the vehicle will respawn after DESTROYED_RESPAWN_DELAY seconds. If abandoned, the vehicle will also respawn after ABANDONED_RESPAWN_DELAY seconds. 
 * 	if ABANDONED_RESPAWN_DELAY == 0, the vehicle won't respawn if abandoned. 
 *
 *	example: null = [this, "HELLCAT2", 120, 240] execVM "dl_veh_respawn.sqf";
 *			 The Hellcat, whose public var is HELLCAT2 (you can refer to this name elsewhere in your scripts), will respawn after 120 seconds if destroyed and 240 seconds if abandoned
 *
 *	example 2: null = [this, "AHQ", 10, 0, "_this addAction ['Virtual Ammobox', 'vas\open.sqf', nil, 1.5, false];"] execVM "dl_veh_respawn.sqf";
 * 			   This vehicle, named AHQ, will respawn after 10 seconds, and never respawn if abandoned. It will have a "Viritual Ammobox" action.
 *
 */

dl_veh_updateLocation = {
	private ["_vehicle"];

	_vehicle = _this select 0;
	_newPos = _this select 1;
	_newDir = _this select 2;
	_vehicle setVariable ["RES_ORIG_LOC", _newPos];
	_vehicle setVariable ["RES_ORIG_DIR", _newDir];
	//if (debugMode == 1) then { diag_log format ["updated %1's location to %2 (%3)", vehicleVarName _vehicle, _newPos, _newDir]; };
};

dl_veh_initParams = { // should be executed on every client
	private ["_vehicle"];
	_vehicle = (_this select 0);
	_name = (_this select 1);
	_init = (_this select 2);

	//if (debugMode == 1) then { diag_log format["initializing %1: %2", _name, _init]; };
	_vehicle call compile format ["%1 = _this; publicVariable ""%1""; " + _init, _name];
	_vehicle setVehicleVarName _name;
};

dl_veh_addVehtoArray = {
	_vehicle = (_this select 0);
	_name = (_this select 1);
	_destroyedRespawnDelay = (_this select 2);
	_abandonedRespawnDelay = (_this select 3);
	_abandon = if (_abandonedRespawnDelay == 0) then { false } else { true };
	_init = if (count _this > 4) then { (_this select 4) } else { "" };

	_vehicle setVariable ["RES_NAME", _name];
	_vehicle setVariable ["RES_DESTROY_RESPAWN_DELAY", _destroyedRespawnDelay];
	_vehicle setVariable ["RES_ABANDON_RESPAWN_DELAY", _abandonedRespawnDelay];
	_vehicle setVariable ["RES_ABANDON", _abandon];
	_vehicle setVariable ["RES_ABANDON_LISTEN", false];
	_vehicle setVariable ["RES_ABANDON_WARN", true];
	_vehicle setVariable ["RES_ABANDON_TIME", 0];
	_vehicle setVariable ["RES_INIT", _init];
	_vehicle setVariable ["RES_ORIG_TYPE", typeOf _vehicle];
	_vehicle setVariable ["RES_ORIG_LOC", getPos _vehicle];
	_vehicle setVariable ["RES_ORIG_DIR", getDir _vehicle];

	[[_vehicle, _name, _init], "dl_veh_initParams", true, true] spawn BIS_fnc_MP; // init parameters
	//if (debugMode == 1) then { diag_log format["INS_VEH_RESPAWN: adding %1 to respawn array", _name]; };

	vehicleArray = vehicleArray + [_vehicle];
};

// waitUntil { !isNil "doneInit"; }; // a good idea, but not necessary
if (isNil "vehicleArray") then { vehicleArray = []; publicVariable "vehicleArray"; };
if (isServer) then { // server loop
	if (count _this == 0) then { // called script to loop
		//if (debugMode == 1) then { diag_log format["INS_VEH_RESPAWN: starting respawn loop"]; };
		while { true } do {
			{
				_veh = _x;

				_name = _veh getVariable "RES_NAME";
				_destroyedRespawnDelay = _veh getVariable "RES_DESTROY_RESPAWN_DELAY";
				_abandonedRespawnDelay = _veh getVariable "RES_ABANDON_RESPAWN_DELAY";
				_abandon = _veh getVariable "RES_ABANDON";
				_abandonedTime = _veh getVariable "RES_ABANDON_TIME";
				_respawn = false;
				_abandoned = false;

				_abandonedListen = _veh getVariable ["RES_ABANDON_LISTEN", false];
				_abandonWarn = _veh getVariable ["RES_ABANDON_WARN", true];

				if (_abandon and !_abandonedListen and (count crew _veh != 0)) then { _abandonedListen = true; };
				if (_abandon and _abandonedListen and (count crew _veh == 0)) then { _abandonedTime = _abandonedTime + 1; };
				if (_abandon and _abandonedListen and (count crew _veh != 0)) then { _abandonedTime = 0; };

				_veh setVariable ["RES_ABANDON_TIME", _abandonedTime];
				_veh setVariable ["RES_ABANDON_LISTEN", _abandonedListen];

				if (_abandon and _abandonedTime > _abandonedRespawnDelay) then { _abandoned = true; _respawn = true; };
				if (_abandonedListen and _abandonedTime > (_abandonedRespawnDelay - 60) and _abandonWarn and (count crew _veh == 0)) then { [format["<t color='#ff6347'>%1</t> will respawn in %2 seconds", _name, _abandonedRespawnDelay - _abandonedTime], true, true] call dl_fnc_hintMP; _abandonWarn = false; };
				_veh setVariable ["RES_ABANDON_WARN", _abandonWarn];

				if (!alive _veh) then { _respawn = true; sleep _destroyedRespawnDelay; };
				if (_respawn) then {
					_init = _veh getVariable "RES_INIT";
					_type = _veh getVariable "RES_ORIG_TYPE";
					_origLoc = _veh getVariable "RES_ORIG_LOC";
					_origDir = _veh getVariable "RES_ORIG_DIR";

					_reason = if (_abandoned) then {"abandoned"} else {"destroyed"};
					[format["respawning %1 vehicle <t color = '#ff6347'>%2</t>", _reason, _name], true, true] call dl_fnc_hintMP;

					vehicleArray = vehicleArray - [_veh];
					deleteVehicle _veh;
					
					sleep 3;

					_veh = _type createVehicle _origLoc;
					_veh setDir _origDir;
					[_veh, _name, _destroyedRespawnDelay, _abandonedRespawnDelay, _init] call dl_veh_addVehtoArray;
				};
			} forEach vehicleArray;

			sleep 1;
		};
	} else { // called script to add vehicle to loop
		_attrs = _this;
		_attrs call dl_veh_addVehtoArray;
	};
};

// ---------------------------------------
//	helper functions - add to some functions file or leave here
// ---------------------------------------

dl_fnc_addEventHandlerMPHelper = {
	_object = _this select 0;
	_type = _this select 1;
	_action = _this select 2;

	_object addEventHandler [_type, _action];
};

dl_fnc_addEventHandlerMP = {
	_object = _this select 0;
	_type = _this select 1;
	_action = _this select 2;

	[[_object, _type, _action], "dl_fnc_addEventHandlerMPHelper", true, true] spawn BIS_fnc_MP;
};

dl_fnc_addActionMPHelper = {
	private ["_object", "_title", "_script", "_args", "_showInWindow", "_hideOnUse", "_condition"];

	_object = _this select 0;
	_title = _this select 1;
	_script = _this select 2;
	_args = _this select 3;
	_showInWindow = _this select 4;
	_hideOnUse = _this select 5;
	_condition = _this select 6;

	_object addAction [_title, _script, _args, 1, _showInWindow, _hideOnUse, "", _condition];
};

dl_fnc_addActionMP = {
	private ["_object", "_title", "_script", "_args", "_showInWindow", "_hideOnUse", "_condition"];

	_object = _this select 0;
	_title = _this select 1;
	_script = _this select 2;
	_args = _this select 3;
	_showInWindow = _this select 4;
	_hideOnUse = _this select 5;
	_condition = _this select 6;

	[[_object, _title, _script, _args, _showInWindow, _hideOnUse, _condition], "dl_fnc_addActionMPHelper", true, true] spawn BIS_fnc_MP;
};

dl_fnc_hintMP = {
	_message = _this select 0;
	_obj = _this select 1;
	_jip = _this select 2;

	[_message, "dl_fnc_hintMPHelper", _obj, _jip] spawn BIS_fnc_MP;
};

dl_fnc_hintMPHelper = {
	hint _this;
};