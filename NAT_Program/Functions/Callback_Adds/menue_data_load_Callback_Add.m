function menue_data_load_Callback_Add (hObject, handles)
%MENUE_DATA_LOAD_CALLBACK_ADD Summary of this function goes here
%   Detailed explanation goes here

% aktuellen Speicherort für Konfigurationen auslesen:
file = handles.Current_Settings.Files.Save.Result;
% Userabfrage nach Speicherort
[file.Name,file.Path] = uigetfile([...
	{'*.mat','Simulationsdaten'};...
	{'*.*','Alle Dateien'}],...
	'Laden von Simulationsdaten...',...
	[file.Path,filesep]);
% Überprüfen, ob gültiger Speicherort angegeben wurde:
if ~isequal(file.Name,0) && ~isequal(file.Path,0)
	% Falls, ja, Entfernen der Dateierweiterung vom Dateinamen:
	[~, file.Name, file.Exte] = fileparts(file.Name);
	% leztes Zeichen ("/") im Pfad entfernen:
	file.Path = file.Path(1:end-1);
	% Daten laden und Einstellungen dieser Daten wiederherstellen:
	load('-mat', [file.Path,filesep,file.Name,file.Exte]);
	handles.NAT_Data.Result = Result;
	handles.NAT_Data.Load_Infeed_Data = Load_Infeed_Data;
	handles.NAT_Data.Grid = Grid;
% 	handles.Current_Settings = Result.Current_Settings;
	% aktuellen Speicherort übernehmen:
	handles.Current_Settings.Files.Save.Result = file;
% 	handles.
	% Netz zurücksetzen:
	handles.Current_Settings.Files.Grid.Name = [];
	if isfield(handles,'sin')
		handles = rmfield(handles,'sin');
	end
	try
% 		db = handles.Current_Settings.Load_Database;
% 		load([db.Path,filesep,db.Name,filesep,db.Name,'.mat']);
% 		handles.Current_Settings.Database.setti = setti;
% 		handles.Current_Settings.Database.files = files;
		
	catch ME
		% alte Datenbankeinstellungen entfernen:
		if isfield(handles.Current_Settings.Database,'setti')
			handles.Current_Settings.Database = rmfield(...
				handles.Current_Settings.Database,'setti');
		end
		if isfield(handles.Current_Settings.Database,'files')
			handles.Current_Settings.Database = rmfield(...
				handles.Current_Settings.Database,'files');
		end
		
		% User informieren:
		helpdlg({'Simulationsdaten erfolgreich geladen.',...
			'Datenbank konnte nicht geladen werden,',...
			'bitte Datenbankpfad erneut angeben!'});
		disp('Fehler beim Laden der Datenbankeinstellungen:');
		disp(ME.message);
	end
end

% Anzeigen aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);
end

