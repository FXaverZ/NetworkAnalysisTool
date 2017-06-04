function push_set_path_database_Callback_Add (hObject, handles)
%PUSH_SET_PATH_DATABASE_CALLBACK_ADD Summary of this function goes here
%   Detailed explanation goes here


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
	'Auswählen des Hauptordners einer Datenbank:');
if ischar(Main_Path)
	[pathstr, name] = fileparts(Main_Path);
	% Die Einstellungen übernehmen:
	handles.Current_Settings.Load_Database.Path = pathstr;
	handles.Current_Settings.Load_Database.Name = name;
	% Laden der Datenbankeinstellungen:
	try
		load([pathstr,filesep,name,filesep,name,'.mat']);
		handles.Current_Settings.Load_Database.setti = setti;
		handles.Current_Settings.Load_Database.files = files;
		handles.Current_Settings.Load_Database.valid = 1;
		helpdlg('Datenbank erfolgreich geladen!', 'Laden der Datenbank...');
	catch ME %#ok<NASGU>
		% Falls keine gültige Datenbank geladen werden konnte, Fehlermeldung an User:
		errordlg('Am angegebenen Pfad wurde keine gültige Datenbank gefunden!',...
			'Fehler beim laden der Datenbank...');
		% Anzeige aktualisieren:
		handles = refresh_display_NAT_main_gui(handles);
		handles.Current_Settings.Load_Database.valid = 0;
	end
end

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);
% handles-Structure aktualisieren:
guidata(hObject, handles);
end

