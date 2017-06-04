function push_network_calculation_start_Callback_Add (hObject, handles)
% hObject    Link zur Grafik push_network_calculation_start (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

set(handles.push_network_calculation_start, 'Enable', 'off');
set(handles.push_cancel, 'Enable', 'on');
pause(0.01);

if handles.Current_Settings.Simulation.Use_Scenarios
	handles = network_scenario_calculation(handles);
else
	handles = network_calculation_grid(handles);
end

% update GUI:
handles = refresh_display_NAT_main_gui(handles);
set(handles.push_cancel, 'Enable', 'off');

% update handles structure:
guidata(hObject, handles);
end

