function NAT_main_gui_CloseRequestFcn_Impl(~, handles)
% hObject    Link zur Grafik NAT_main_gui (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

user_response = questdlg(['Should the program be closed and all',...
	' settings be saved for later use?'],'Beenden?',...
	'Save & Close', 'Close', 'Cancel', 'Cancel');
switch user_response
	case 'Cancel'
		% nichts unternehmen
	case 'Close'
		handles.text_message_main_handler.add_line('Closing NAT without saving current configuration.');
		% Kein speichern der akutellen Einstellungen, nur beenden des Programms:
		if isfield(handles, 'sin')
			handles.sin.close_file_in_application;
			handles.sin.close_database;
		end
		refresh_message_text_operation_finished (handles);
		delete(handles.NAT_main_gui);
	case 'Save & Close'
		handles.text_message_main_handler.add_line('Closing NAT. Saving current configuration...');
		% Konfiguration speichern:
		Current_Settings = handles.Current_Settings;
		System = handles.System; %#ok<NASGU>
		file = Current_Settings.Files.Last_Conf;
		% Falls Pfad der Konfigurationsdatei nicht vorhanden ist, Ordner erstellen:
		if ~isdir(file.Path)
			mkdir(file.Path);
		end
		save([file.Path,filesep,file.Name,file.Exte],'Current_Settings','System');
		if isfield(handles, 'sin')
			handles.sin.close_file_in_application;
			handles.sin.close_database;
		end
		handles.text_message_main_handler.add_line('... done.');
		refresh_message_text_operation_finished (handles);
		delete(handles.NAT_main_gui);
end

