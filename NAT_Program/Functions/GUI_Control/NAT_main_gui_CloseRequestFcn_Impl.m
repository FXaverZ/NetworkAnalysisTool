function NAT_main_gui_CloseRequestFcn_Impl(~, handles)
% hObject    Link zur Grafik NAT_main_gui (siehe GCBO)
% ~			 nicht benötigt (MATLAB spezifisch)
% handles    Struktur mit Grafiklinks und User-Daten (siehe GUIDATA)

mh = handles.text_message_main_handler;

user_response = questdlg(['Should the program be closed and all',...
	' settings be saved for later use?'],'Beenden?',...
	'Save & Close', 'Close', 'Cancel', 'Cancel');
switch user_response
	case 'Cancel'
		% nichts unternehmen
	case 'Close'
		mh.add_line('Closing NAT without saving current configuration.');
		% Kein speichern der akutellen Einstellungen, nur beenden des Programms:
		if isfield(handles, 'sin')
			handles.sin.close_file_in_application;
			handles.sin.close_database;
		end
		mh.reset_sub_logs();
		refresh_message_text_operation_finished (handles);
		delete(handles.NAT_main_gui);
	case 'Save & Close'
		mh.add_line('Closing NAT. Saving current configuration...');
		% Konfiguration speichern:
		Current_Settings = handles.Current_Settings;
		System = handles.System; %#ok<NASGU>
		file = Current_Settings.Files.Last_Conf;
		% Falls Pfad der Konfigurationsdatei nicht vorhanden ist, Ordner erstellen:
		if ~isfolder(file.Path)
			mkdir(file.Path);
		end
		save([file.Path,filesep,file.Name,file.Exte],'Current_Settings','System');
		if isfield(handles, 'sin')
			handles.sin.close_file_in_application;
			handles.sin.close_database;
		end
		mh.add_line('... done.');
		mh.reset_sub_logs();
		refresh_message_text_operation_finished (handles);
		delete(handles.NAT_main_gui);
end

