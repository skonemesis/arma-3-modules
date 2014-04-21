if (timeUntilNextCAS > 0) exitWith { hint parseText format["<t color='#6775cf'>%1</t> seconds until CAS is available", timeUntilNextCAS]; };

deleteMarker "maxDist";
deleteMarker "minDistOrig";
deleteMarker "CAS_TARGET";
deleteMarker "CAS_ORIG";

maxDisReq = (_this select 3) select 0;
_casType = (_this select 3) select 1;

_borderMarker = createMarkerLocal["maxDist", getPos player];
_borderMarker setMarkerShapeLocal "ELLIPSE";
_borderMarker setMarkerSizeLocal[maxDisReq, maxDisReq];
_borderMarker setMarkerColorLocal "ColorRed";
_borderMarker setMarkerBrushLocal "Border";

_borderMarker = createMarkerLocal["minDistOrig", getPos player];
_borderMarker setMarkerShapeLocal "ELLIPSE";
_borderMarker setMarkerSizeLocal[3000, 3000];
_borderMarker setMarkerColorLocal "ColorBlue";
_borderMarker setMarkerBrushLocal "Border";

mapListen = true;
INS_CAS_casRequest = false;

timeSlept = 0;
hint "Indicate CAS target by shift-clicking a position on the map, then alt-click to choose where the CAS will originate from (straight line from that point)";

targetPos = [0, 0, 0];
origPos = [0, 0, 0];
playerPos = getPos player;
openMap true;

while { mapListen } do {
	onMapSingleClick {
		if (_shift) then {
			if ((playerPos distance _pos) > maxDisReq) then {
				hintSilent format ['Max distance to target is limited to %1m', maxDisReq];
				deleteMarker 'CAS_TARGET';
			} else { 
				targetPos = _pos;

				deleteMarker 'CAS_TARGET';
				_marker = createMarker['CAS_TARGET', _pos];
				_marker setMarkerType 'mil_destroy';
				_marker setMarkerSize[0.5, 0.5];
				_marker setMarkerColor 'ColorRed';
				_marker setMarkerText ' TARGET';

				if (!(str targetPos == '[0,0,0]') && !(str origPos == '[0,0,0]')) then {
					mapListen = false; INS_CAS_casRequest = true; INS_CAS_abortCAS = false;
				}; 
			};

			onMapSingleClick "";
		};

		if (_alt) then {
			if (str targetPos == '[0,0,0]') then {
				hintSilent 'Set target position first.'
			} else {
				if ((_pos distance playerPos) < 3000) then {
					hintSilent format ['Min distance from target is limited to %1m', 3000];
					deleteMarker 'CAS_ORIG';
				} else { 
					origPos = _pos;
					//origPos set [2, 500];

					deleteMarker 'CAS_ORIG';
					_marker = createMarker['CAS_ORIG', _pos];
					_marker setMarkerType 'mil_destroy';
					_marker setMarkerSize[0.5, 0.5];
					_marker setMarkerColor 'ColorBlue';
					_marker setMarkerText ' ORIGIN';
					
					if (!(str targetPos == '[0,0,0]') && !(str origPos == '[0,0,0]')) then {
						mapListen = false; INS_CAS_casRequest = true; INS_CAS_abortCAS = false;
					};
				};
			};
			
			onMapSingleClick "";
		}; 
	};

	sleep 0.1;
	timeSlept = timeSlept + 0.1;
	if (timeSlept > 30) then { hint "CAS request timed out"; mapListen = false;  };
};

deleteMarker "maxDist";
deleteMarker "minDistOrig";

if (!INS_CAS_casRequest) then {
	call INS_CAS_finishCAS;
} else {
	call INS_CAS_removeMenuItems;
	switch (_casType) do {
		case "JDAM": { [] execVM "cas\functions\casJDAM.sqf" };
		case "CBU": { [] execVM "cas\functions\casCBU.sqf" };
		case "COMBO": { [] execVM "cas\functions\casCombo.sqf" };
		case "GBU": { [] execVM "cas\functions\casGuided.sqf" };
		case "GAU": { [] execVM "cas\functions\casWipeout.sqf" };
		case "HELO": { [] execVM "cas\functions\casHeli.sqf" };
	};
};