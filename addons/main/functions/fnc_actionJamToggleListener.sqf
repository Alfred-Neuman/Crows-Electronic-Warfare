#include "script_component.hpp"
/*/////////////////////////////////////////////////
Author: Crowdedlight
			   
File: fnc_actionJamToggleListener.sqf
Parameters: netid, enabled
Return: none

Listens to action event to sync toggle across all clients

*///////////////////////////////////////////////
params ["_netId", "_enabled"];

// making sure object hasn't been removed during event transit time.
if (!(_netId in GVAR(jamMap))) exitWith {};

// get value and update the enabled value
private _jammer = GVAR(jamMap) get _netId;
_jammer set [3, _enabled];

// save changes to map
GVAR(jamMap) set [_netId, _jammer];

// show jammers in the spectrum
if (_enabled) then {
	[QEGVAR(spectrum,addBeacon), [_jamObj, 433, 300, "sweep"]] call CBA_fnc_globalEventJIP;
} else {
	[QEGVAR(spectrum,removeBeacon), [_jamObj]] call CBA_fnc_globalEventJIP;
};

