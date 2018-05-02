function push_set_path_database_Callback_Add (hObject, handles)
%PUSH_SET_PATH_DATABASE_CALLBACK_ADD Summary of this function goes here
%   Detailed explanation goes here

buttontext = get(handles.push_set_path_database, 'String');
handles.text_message_main_handler.add_line('"',buttontext,'" pushed, connect DLE database:');
handles.text_message_main_handler.level_up();

% alte Datenbankeinstellungen entfernen:
if isfield(handles.Current_Settings.Load_Database,'setti')
	handles.Current_Settings.Load_Database = rmfield(...
		handles.Current_Settings.Load_Database,'setti');
end
if isfield(handles.Current_Settings.Load_Database,'files')
	handles.Current_Settings.Load_Database = rmfield(...
		handles.Current_Settings.Load_Database,'files');
end

% Userabfrage nach neuen Datenbankpfad:
Main_Path = uigetdir(handles.Current_Settings.Load_Database.Path,...
	'Selection of DLE database main folder...');
if ischar(Main_Path)
	[pathstr, name] = fileparts(Main_Path);
	% Die Einstellungen übernehmen:
	handles.Current_Settings.Load_Database.Path = pathstr;
	handles.Current_Settings.Load_Database.Name = name;
	% Laden der Datenbankeinstellungen:
	try
		handles.text_message_main_handler.add_line('Connecting "',...
			handles.Current_Settings.Load_Database.Name,'" from "',...
			handles.Current_Settings.Load_Database.Path,'"');
		load([pathstr,filesep,name,filesep,name,'.mat']);
		handles.Current_Settings.Load_Database.setti = setti;
		handles.Current_Settings.Load_Database.files = files;
		handles.Current_Settings.Load_Database.valid = 1;
		str = 'DLE database successfully connected!';
		handles.text_message_main_handler.add_line(str);
		helpdlg(str, 'Connection of DLE database...');
	catch ME %#ok<NASGU>
		% Falls keine gültige Datenbank geladen werden konnte, Fehlermeldung an User:
		errorstr = 'At the given path was no vaild DLE database found!';
		handles.text_message_main_handler.add_line('Error: ', errorstr);
		errordlg(errorstr,...
			'Error connecting DLE database...');
		% Anzeige aktualisieren:
		handles = refresh_display_NAT_main_gui(handles);
		handles.Current_Settings.Load_Database.valid = 0;
	end
else
	handles.text_message_main_handler.add_line('Canceled by user');
end

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);
refresh_message_text_operation_finished (handles);
% handles-Structure aktualisieren:
guidata(hObject, handles);
end

