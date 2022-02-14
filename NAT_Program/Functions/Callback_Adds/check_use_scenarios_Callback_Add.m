function check_use_scenarios_Callback_Add (hObject, handles)
% hObject    Link zur Grafik check_use_scenarios (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

handles.Current_Settings.Simulation.Use_Scenarios = get(hObject,'Value');

% !!! HAS TO BE REFACTORED !!!
if handles.Current_Settings.Simulation.Use_Scenarios
	% Re-Load the Szenarios:
	user_response = 'Yes';
	if isfield(handles.Current_Settings.Simulation, 'Scenarios')
		user_response = questdlg(['Should the current sceanrios setting be replaced ',...
			'by the settings in ''get_scenarios.m''?'],'Scenario data allready exists...',...
			'Yes','Keep old settings', 'Cancel', 'Keep old settings');
	end
	switch user_response
		case 'Yes'
			% load scenario settings:
			handles = get_scenarios(handles);
		case 'Keep old settings'
			% Do nothing
		otherwise
			% return
			% Anzeige aktualisieren:
			refresh_display_NAT_main_gui(handles);
			return;
	end
end

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);
end

