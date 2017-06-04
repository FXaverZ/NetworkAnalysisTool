function menue_data_save_Callback_Add (hObject, handles)
%MENUE_DATA_SAVE_CALLBACK_ADD Summary of this function goes here
%   Detailed explanation goes here

% aktuellen Speicherort für Simulationsdaten auslesen:
file = handles.Current_Settings.Files.Save.Result;
% Userabfrage nach Speicherort
[file.Name,file.Path] = uiputfile([...
	{'*.mat','Simulationsdaten'};...
	{'*.*','Alle Dateien'}],...
	'Speicherort für aktuelle Simulationsdaten...',...
	[file.Path,filesep,file.Name,file.Exte]);
% Überprüfen, ob gültiger Speicherort angegeben wurde:
if ~isequal(file.Name,0) && ~isequal(file.Path,0)
	% Falls, ja, Entfernen der Dateierweiterung vom Dateinamen:
	[~, file.Name, file.Exte] = fileparts(file.Name);
	% leztes Zeichen ("/") im Pfad entfernen:
	file.Path = file.Path(1:end-1);
	% aktuellen Speicherort übernehmen:
	handles.Current_Settings.Files.Save.Result = file;
	handles = save_simulation_data(handles);
end

% User informieren:
helpdlg('Simulationsdaten erfolgreich gespeichert');

% Anzeige aktualisieren:
handles = refresh_display_NAT_main_gui(handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);

end

