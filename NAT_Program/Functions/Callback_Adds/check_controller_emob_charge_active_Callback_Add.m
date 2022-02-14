function check_controller_emob_charge_active_Callback_Add (hObject, handles)
%CHECK_CONTROLLER_EMOB_CHARGE_ACTIVE_CALLBACK_ADD Summary of this function goes here
%   Detailed explanation goes here

handles.Current_Settings.Simulation.Controller.El_Mobility.Charge_Controller.Active = ...
	get(hObject,'Value');


% !!! HAS TO BE REFACTORED !!!
if handles.Current_Settings.Simulation.Controller.El_Mobility.Charge_Controller.Active
	% Re-Load the Controller-Settings:
	user_response = questdlg(['Should the current controller settings be replaced ',...
		'by the settings in ''get_controller_settings.m''?'],...
		'Re-loading of controller settings...',...
		'Yes','Keep old settings', 'Cancel', 'Keep old settings');
	switch user_response
		case 'Yes'
			% load scenario settings:
			handles = get_controller_settings(handles);
		otherwise
			% Do nothing
	end
end

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);

end

