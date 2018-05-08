function push_network_calculation_start_Callback_Add (hObject, handles)
% hObject    Link zur Grafik push_network_calculation_start (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

mh = handles.text_message_main_handler;

buttontext = get(handles.push_network_calculation_start, 'String');
mh.add_line('"',buttontext,'" pushed, start with calculations:');
mh.level_up();

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
refresh_message_text_operation_finished (handles);
set(handles.push_cancel, 'Enable', 'off');

% update handles structure:
guidata(hObject, handles);
end

