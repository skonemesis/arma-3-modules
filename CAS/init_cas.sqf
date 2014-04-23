if (isServer) then {
	onPlayerConnected {
		publicVariable "casNumRequestsBLUFOR";
		publicVariable "casNumRequestsOPFOR";
	};
};

if (isNil "INS_CAS_abortCAS") then { INS_CAS_abortCAS = true; };
if (isNil "INS_CAS_waitCAS") then { INS_CAS_waitCAS = false; };
if (isNil "timeUntilNextCAS") then { timeUntilNextCAS = 0; publicVariable "timeUntilNextCAS"; };

INS_CAS_canCallCAS = {
	_can_call = false;
	switch (side player) do {
		case west: { 
			if (casNumRequestsBLUFOR > 0) then { _can_call = true; } 
			else {
				if (casNumRequestsBLUFOR == -1) then { _can_call = true; };
			};
		};
		
		case east: {
			if (casNumRequestsOPFOR > 0) then { _can_call = true; } 
			else {
				if (casNumRequestsOPFOR == -1) then { _can_call = true; };
			};
		};
	};

	_can_call
};

CAS_ACTION_ID = player addAction ["<t color='#6775cf'>Request CAS</t>", "cas\casMenu.sqf", nil, 1.5, false, false, "", "'ItemGPS' in (assignedItems _this) and 'ItemRadio' in (assignedItems _this) and !INS_CAS_waitCAS and call INS_CAS_canCallCAS"];

player addEventHandler ["Respawn", {
	CAS_ACTION_ID = player addAction ["<t color='#6775cf'>Request CAS</t>", "cas\casMenu.sqf", nil, 1.5, false, false, "", "'ItemGPS' in (assignedItems _this) and 'ItemRadio' in (assignedItems _this) and !INS_CAS_waitCAS and call INS_CAS_canCallCAS"];
}];
