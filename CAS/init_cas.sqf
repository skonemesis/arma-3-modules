if (isNil "INS_CAS_abortCAS") then { INS_CAS_abortCAS = true; };
if (isNil "INS_CAS_waitCAS") then { INS_CAS_waitCAS = false; };
if (isNil "timeUntilNextCAS") then { timeUntilNextCAS = 0; publicVariable "timeUntilNextCAS"; };

CAS_ACTION_ID = player addAction ["<t color='#6775cf'>Request CAS</t>", "cas\casMenu.sqf", nil, 1.5, false, false, "", "'ItemGPS' in (assignedItems _this) and 'ItemRadio' in (assignedItems _this) and !INS_CAS_waitCAS"];

player addEventHandler ["Respawn", {
	CAS_ACTION_ID = player addAction ["<t color='#6775cf'>Request CAS</t>", "cas\casMenu.sqf", nil, 1.5, false, false, "", "'ItemGPS' in (assignedItems _this) and 'ItemRadio' in (assignedItems _this) and !INS_CAS_waitCAS"];
}];