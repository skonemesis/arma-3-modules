player removeAction CAS_ACTION_ID;

INS_CAS_removeMenuItems = {
	player removeAction CAS_ACTION_ID;
	player removeAction TITLE_ACTION_ID;
	player removeAction JDAM_ACTION_ID;
	player removeAction CBU_ACTION_ID;
	player removeAction COMBO_ACTION_ID;
	player removeAction GUIDED_ACTION_ID;
	player removeAction A164C_ACTION_ID;
	player removeAction HELI_ACTION_ID;
	player removeAction CAS_CANCEL_ID;

	CAS_ACTION_ID = player addAction ["<t color='#6775cf'>Request CAS</t>", "cas\casMenu.sqf", nil, 1.5, false, false, "", "'ItemGPS' in (assignedItems _this) and 'ItemRadio' in (assignedItems _this) and !INS_CAS_waitCAS"];
};

_folderpath = "cas\functions\cas_pick_target.sqf";
TITLE_ACTION_ID = player addAction ["<t color='#6775cf'>CAS Options: </t>", "", nil, 1.5, false, false, "!INS_CAS_waitCAS"];
JDAM_ACTION_ID = player addAction ["  CAS (JDAM)", _folderpath, [500, "JDAM"], 1.5, false, true, "!INS_CAS_waitCAS"];
CBU_ACTION_ID = player addAction ["  CAS (CBU)", _folderpath, [500, "CBU"], 1.5, false, true, "!INS_CAS_waitCAS"];
COMBO_ACTION_ID = player addAction ["  CAS (JDAM/CBU)", _folderpath, [500, "COMBO"], 1.5, false, true, "!INS_CAS_waitCAS"];
GUIDED_ACTION_ID = player addAction ["  CAS (GUIDED)", _folderpath, [500, "GBU"], 1.5, false, true, "!INS_CAS_waitCAS"];
A164C_ACTION_ID = player addAction ["  CAS (A-164C)", _folderpath, [1000, "GAU"], 1.5, false, true, "!INS_CAS_waitCAS"];
HELI_ACTION_ID = player addAction ["  CAS (Helo)", _folderpath, [1000, "HELO"], 1.5, false, true, "!INS_CAS_waitCAS"];
CAS_CANCEL_ID = player addAction ["  <t color='#ff6347'>Exit CAS Menu</t>", INS_CAS_removeMenuItems, nil, 1.5, false, true, "!INS_CAS_waitCAS"];