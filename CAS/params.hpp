#include "config.hpp"

class TitleLineCAS { title = "Close Air Support ---------"; values[] = {0, 0}; texts[] = {"", ""}; default = 0; };

class casPlayerTimeout {
	title = "		Time in between player CAS requests (seconds)";
	values[] = {10, 20, 30, 40, 50, 60, 70, 80};
	default = CAS_DEF_casPlayerTimeout;
};

class casPlayerTimeLimit {
	title = "		Time in available to player controlled CAS (in seconds)";
	values[] = {30, 60, 90, 120, 150, 180, 210, 240};
	default = CAS_DEF_casPlayerTimeLimit;
};

class casAITimeout {
	title = "		Time in between AI CAS requests (in seconds)";
	values[] = {10, 20, 30, 40, 50, 60, 70, 80};
	default = CAS_DEF_casAITimeout;
};

class casNumRequestsBLUFOR {
	title = "		Number of times BLUFOR can call CAS";
	values[] = {-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
	texts[] = {"Unlimited", "Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten"};
	default = CAS_DEF_casNumRequestsBLUFOR;
};

class casNumRequestsOPFOR {
	title = "		Number of times OPFOR can call CAS";
	values[] = {-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
	texts[] = {"Unlimited", "Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten"};
	default = CAS_DEF_casNumRequestsOPFOR;
};