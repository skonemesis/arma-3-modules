/*  dl_group_manager.sqf
 *	usage: add:
 *		   [] execVM "dl_group_manager.sqf";
 *		   to your init.sqf (executed only for players) 
 *
 *	Group management from the action menu. This did not start out my script. I found a workable version in 
 * 	another mission. I modified it to add the accept/deny system as well as fixing the "request group lead" 
 * 	function not working if the command was not executed on the machine where the group was local. The code has also been 
 * 	cleaned and refactored. */

dl_groups_joinGroup = {
	[player] join cursorTarget;
	hint parseText format ["Joined group <t color='#6775cf'>%1</t>", group player];
	[nil, player] call dl_groups_removeActions;
};

dl_groups_dismissAI = {
	(group player) call dl_fnc_dismissAIFromGroup;
	hint parseText format ["Dismissed AI in group <t color='#6775cf'>%1</t>", group player];
	[nil, player] call dl_groups_removeActions;
};

dl_groups_leaveGroup = {
	_cGroup = group player;
	if (leader group player == player) then {
		_curGroup = [];
		_curGroup = units group player;
		_newLead = player;

		while {_newLead == player} do { _newLead = _curGroup select (floor(random(count _curGroup))); sleep 1.0; };
		(group player) selectLeader _newLead;
	};

	[player] join grpNull;
	hint parseText format ["Left group <t color='#6775cf'>%1</t>", _cGroup];
	[nil, player] call dl_groups_removeActions;
};

dl_groups_leadGroup = {
	group player selectLeader player;
	hint parseText format ["Leading group <t color='#6775cf'>%1</t>", group player];
	[nil, player] call dl_groups_removeActions;	
};

dl_groups_quitLead = {
	_curGroup = [];
	_curGroup = units group player;
	_newLead = player;

	while {_newLead == player} do { _newLead = _curGroup select (floor(random(count _curGroup))); sleep 1.0; };

	(group player) selectLeader _newLead;
	hint parseText format ["No longer leading <t color='#6775cf'>%1</t>", group player];
	[nil, player] call dl_groups_removeActions;	
};

dl_groups_removeActions = {
	player removeAction dl_groups_title;
	player removeAction dl_groups_joinGroup;
	player removeAction dl_groups_dismissAI;
	player removeAction dl_groups_leaveGroup;
	player removeAction dl_groups_leadGroup;
	player removeAction dl_groups_quitLead;
	
	player removeAction dl_groups_requestLead;
	player removeAction dl_groups_leadAccept;
	player removeAction dl_groups_leadDecline;
	player removeAction dl_groups_exitMenu;

	dl_groups_groupActions = player addAction["<t color='#6775cf'>Groups Menu</t>", dl_groups_addActions, nil, 1.05, false, false, "", "_target == vehicle _this || _target == _this"];
};

dl_groups_addActions = {
	player removeAction dl_groups_groupActions;

	dl_groups_title = player addAction["<t color='#6775cf'>Group Options:</t>", "", nil, 1.05, false, false];
	dl_groups_joinGroup = player addAction["  Join Group", dl_groups_joinGroup, nil, 1.05, false, false, "", "(cursorTarget distance _this) < 20 && side cursorTarget == side _this && !(group player == group cursorTarget)"];
	dl_groups_dismissAI = player addAction["  Dismiss AI", dl_groups_dismissAI, nil, 1.05, false, false, "", "count ((group _this) call dl_fnc_getAIinGroup) != 0 && (leader group _this == _this)"];
	dl_groups_leaveGroup = player addAction["  Leave Group", dl_groups_leaveGroup, nil, 1.05, false, false, "", "(count units group _this) > 1"];
	dl_groups_leadGroup = player addAction["  Become Group Lead", dl_groups_leadGroup, nil, 1.05, false, false, "", "(count units group _this) > 1 && leader group _this != _this && !(isPlayer leader group _this)"];
	dl_groups_requestLead = player addAction["  Request Group Lead", {
		call compile format ["dl_GROUP_REQUEST_%1 = [true, '%2']", name leader group player, name player];
		publicVariable format["dl_GROUP_REQUEST_%1", name leader group player];

		format["dl_GROUP_REQUEST_RESPONSE_%1", name leader group player] addPublicVariableEventHandler {
			_response = _this select 1;	
			hint str _response;
			if (_response) then { 
				[[group player, player], "dl_helper_doSetLeaderMP", group player] spawn BIS_fnc_MP;
				hint parseText format ["Leading group <t color='#6775cf'>%1</t>", group player];
			};
		};

		call dl_groups_removeActions;
	}, nil, 1.05, false, false, "", "(count units group _this) > 1 && leader group _this != _this && isPlayer leader group _this"];
	dl_groups_leadAccept = player addAction["  Accept Leadership Request", {
		call compile format ["dl_GROUP_REQUEST_%1 = [false, '%1']", name player];
		call compile format ["dl_GROUP_REQUEST_RESPONSE_%1 = true", name player];
		publicVariable format["dl_GROUP_REQUEST_%1", name player];
		publicVariable format["dl_GROUP_REQUEST_RESPONSE_%1", name player];
		call dl_groups_removeActions;
	}, nil, 1.05, false, false, "", format["if (isNil 'dl_GROUP_REQUEST_%1') then {false} else {(dl_GROUP_REQUEST_%1 select 0)};", name player]];
	dl_groups_leadDecline = player addAction["  Deny Leadership Request", {
		call compile format ["dl_GROUP_REQUEST_%1 = [false, '%1']", name player];
		call compile format ["dl_GROUP_REQUEST_RESPONSE_%1 = false", name player];
		publicVariable format["dl_GROUP_REQUEST_%1", name player];
		publicVariable format["dl_GROUP_REQUEST_RESPONSE_%1", name player];
		call dl_groups_removeActions;
	}, nil, 1.05, false, false, "", format["if (isNil 'dl_GROUP_REQUEST_%1') then {false} else {(dl_GROUP_REQUEST_%1 select 0)};", name player]];
	dl_groups_quitLead = player addAction["  Step Down as Group Lead", dl_groups_quitLead, nil, 1.05, false, false, "", "(count units group _this) > 1 && leader group _this == _this"];
	dl_groups_exitMenu = player addAction["  <t color='#ff6347'>Exit Groups Menu</t>", dl_groups_removeActions, nil, -1.04, false, true];	
};

if (!isNull player) then {
    dl_groups_groupActions = player addAction["<t color='#6775cf'>Groups Menu</t>", dl_groups_addActions, nil, 1.05, false, false, "", "_target == vehicle _this || _target == _this"];
    
    player addEventHandler ["Respawn", {
        dl_groups_groupActions = player addAction["<t color='#6775cf'>Groups Menu</t>", dl_groups_addActions, nil, 1.05, false, false, "", "_target == vehicle _this || _target == _this"];
    }];

    format["dl_GROUP_REQUEST_%1", name player] addPublicVariableEventHandler {
    	if ((_this select 1) select 0) then { hint parseText format ["Group lead request from <t color='#6775cf'>%1</t>", (_this select 1) select 1]; };
	};
};

// ---------------------------------------
//	helper functions - add to some functions file or leave here
// ---------------------------------------

dl_helper_doSetLeaderMP = {
	_group = _this select 0;
	_player = _this select 1;

	_group selectLeader _player;
};

dl_fnc_dismissAIFromGroup = {
	_group = _this;

	{ deleteVehicle _x; } forEach (_group call dl_fnc_getAIinGroup);
};