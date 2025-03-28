#include "script_component.hpp"
/*/////////////////////////////////////////////////
Author: Crowdedlight
			   
File: fnc_addJammerZeus.sqf
Parameters: pos, _unit
Return: none

Zeus dialog to set object as jammer

*///////////////////////////////////////////////
params [["_pos",[0,0,0],[[]],3], ["_unit",objNull,[objNull]]];

//ZEN dialog, just ignore ARES, as that mod itself is EOL and links to ZEN
private _onConfirm = 
{
	params ["_dialogResult", "_in"];
	_dialogResult params
	[
		"_isActiveAtMissionStart",
		"_isVoiceCommsJammer",
		"_isDroneJammer",
		"_radEffective",
		"_radFalloff"
	];
	//Get in params again
	_in params [["_pos",[0,0,0],[[]],3], ["_unit",objNull,[objNull]]];
	
	// if object is null, we spawn a dataterminal on the selected position instead
	if (isNull _unit) then {
		// no obj selected 
		private _posAGL = ASLToAGL _pos;
		private _dataTerminal = createVehicle ["Crows_dataterminal", _posAGL, [], 0, "NONE"];

		// set zeus editable 
		["zen_common_addObjects", [[_dataTerminal], objNull]] call CBA_fnc_serverEvent;

		// set as jam object
		_unit = _dataTerminal;
	};

	private _capabilities = [];	// what types of signals can this jammer counteract?
	if (_isVoiceCommsJammer) then { _capabilities pushBack JAM_CAPABILITY_RADIO };
	if (_isDroneJammer) then { _capabilities pushBack JAM_CAPABILITY_DRONE };

	// broadcast event to all clients and JIP
	[QEGVAR(main,addJammer), [_unit, _radFalloff, _radEffective, _isActiveAtMissionStart, _capabilities]] call CBA_fnc_serverEvent;

	// broadcast sound to server for sound handling - Means we don't get duplicate broadcasts due to JIP.
	// params ["_unit", "_delay", "_range", "_repeat", "_aliveCondition", "_sound", "_startDelay", "_volume"];
	[getPosATL _unit, 50, "crowsEW_jam_start", 3] call EFUNC(sounds,playSoundPos);
	[QEGVAR(sounds,addSound), [_unit, 0.5, 50, true, true, "crowsEW_jam_loop", 3, 3]] call CBA_fnc_serverEvent;
	[QEGVAR(sounds,setSoundEnable), [_unit, _isActiveAtMissionStart]] call CBA_fnc_serverEvent;
};
[
	localize "STR_CROWSEW_Zeus_addjammer_name", 
	[
		["CHECKBOX",localize "STR_CROWSEW_Zeus_addjammer_start_when_placed",[true]], // defaults to true because this is a well established feature
		["CHECKBOX",localize "STR_CROWSEW_Zeus_addjammer_jam_radio",[true]], // defaults to true because this is a well established feature
		["CHECKBOX",localize "STR_CROWSEW_Zeus_addjammer__jam_drones",[false]], // defaults to false because this feature is new and might be unexpected
		["SLIDER",
		[
			localize "STR_CROWSEW_Zeus_addjammer__effective_radius", 
			localize "STR_CROWSEW_Zeus_addjammer_effective_radius_tooltip"	
		],
		[10,5000,200,0] //10 to 5000, default 200 and showing 0 decimal
		],
		["SLIDER",
			[
				localize "STR_CROWSEW_Zeus_addjammer_falloff_radius", 
				localize "STR_CROWSEW_Zeus_addjammer_falloff_radius_tooltip"
			],
			[10,5000,400,0] //10 to 5000, default 300 and showing 0 decimal.
		]
	],
	_onConfirm,
	{},
	_this
] call zen_dialog_fnc_create;