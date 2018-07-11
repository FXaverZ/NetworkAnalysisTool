function push_network_calculation_start_Callback_Add (hObject, handles)
% hObject    Link zur Grafik push_network_calculation_start (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

mh = handles.text_message_main_handler;
ch = handles.cancel_button_main_handler;
wb = handles.waitbar_main_handler;

buttontext = get(handles.push_network_calculation_start, 'String');
mh.reset_display_text();
mh.add_line('"',buttontext,'" pushed, start with calculations:');
mh.level_up();

ch.set_cancel_button(handles.push_network_calculation_start);
wb.reset();

if handles.Current_Settings.Simulation.Use_Scenarios
	handles = network_scenario_calculation(handles);
else
	handles = network_calculation_grid(handles);
end

% Refresh the GUI:
if ~ch.was_cancel_pushed()
	wb.stop();
else
	wb.stop_cancel();
end
ch.reset_cancel_button();
handles = refresh_display_NAT_main_gui(handles);
refresh_message_text_operation_finished (handles);

% update handles structure:
guidata(hObject, handles);
end

