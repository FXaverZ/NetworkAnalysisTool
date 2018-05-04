function push_network_load_Callback_Add (hObject, handles)
%PUSH_NETWORK_LOAD_CALLBACK_ADD Summary of this function goes here
%   Detailed explanation goes here

mh = handles.text_message_main_handler;
mh.add_line('"Load Grid..." pushed, loading single grid model into NAT:');
mh.level_up();

% aktuellen Speicherort für Daten auslesen:
file = handles.Current_Settings.Files.Grid;
% Userabfrage nach Speicherort
[file.Name,file.Path] = uigetfile([...
	{'*.sin','*.sin SINCAL-Netzdatei'};...
	{'*.*','All Files'}],...
	'Load Grid...',...
	[file.Path,filesep]);
% Überprüfen, ob ungültiger Speicherort angegeben wurde:
if isequal(file.Name,0) || isequal(file.Path,0)
	% If not, return to calling function:
	mh.add_line('Canceled by user.');
	% Anzeige des Hauptfensters aktualisieren:
	handles = refresh_display_NAT_main_gui (handles);
	refresh_message_text_operation_finished (handles);
	% update handles structure:
	guidata(hObject, handles);
	return;
end

% ask user for grid-type:
user_response = questdlg(['As which type of Grid should the current one(s) be ',...
	'treated?'],'Grid type?','LV', 'MV', 'Cancel', 'Cancel');
switch user_response
	case 'LV'
		handles.Current_Settings.Grid.Type = 'LV';
	case 'MV'
		handles.Current_Settings.Grid.Type = 'MV';
	otherwise
		% leave function ('Cancel' or 'abort')
		return;
end
mh.add_line(['Grid interpreted as type "',...
	handles.Current_Settings.Grid.Type,'"']);

% Entfernen der Dateierweiterung vom Dateinamen:
[~, file.Name, file.Exte] = fileparts(file.Name);
% leztes Zeichen ("/") im Pfad entfernen:
file.Path = file.Path(1:end-1);
% Änderungen übernehmen:
handles.Current_Settings.Files.Grid = file;

% remove grid variants:
handles.Current_Settings.Simulation.Grid_List = {};
% Set path of grid variants to default value:
handles.Current_Settings.Simulation.Grids_Path = handles.Current_Settings.Files.Main_Path;

% Netzdaten laden:
try
	handles = network_load (handles);
	% Tabelle mit Default-Werten befüllen:
	[handles.Current_Settings.Table_Network, handles.Current_Settings.Data_Extract] = ...
		network_table_reset(handles);
	% clear grids list:
	handles.Current_Settings.Data_Extract.LV_Grids_List = {};
catch ME
	mh.add_error(ME.message);
end

% Anzeige des Hauptfensters aktualisieren:
handles = refresh_display_NAT_main_gui (handles);
refresh_message_text_operation_finished (handles);

% handles-Struktur aktualisieren:
guidata(hObject, handles);
end

