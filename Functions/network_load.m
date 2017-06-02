function handles = network_load (handles)
%LOAD_NETWORK    Summary of this function goes here
%    Detailed explanation goes here

% Version:                 1.0
% Erstellt von:            Franz Zeilinger - 04.02.2013
% Letzte Änderung durch:   Franz Zeilinger - 

if ~isfield(handles, 'sin')
	% Erzeugen der SINCAL-Instanz:
	sin = SINCAL(handles.Current_Settings.Simulation.Parameters{:},...
		'Grid_name', handles.Current_Settings.Grid.Name,...
		'Grid_path', handles.Current_Settings.Grid.Path);
	sin.open_database;
else
	sin = handles.sin;
	sin.update_settings(handles.Current_Settings.Simulation.Parameters{:},...
		'Grid_name', handles.Current_Settings.Grid.Name,...
		'Grid_path', handles.Current_Settings.Grid.Path);
end

% Auslesen der aktuellen Tabelle mit den Elementdaten
sin.table_data_load('Element');

% Element-IDs aller SINCAL-Lasten auslesen:
Grid.P_Q_Node.ids = cell2mat(sin.Tables.Element(...
	strncmp(sin.Tables.Element(:,strcmp(sin.Tables.Element(1,:),'Type')),'Load',4),...
	strcmp(sin.Tables.Element(1,:),'Element_ID')...
	));

%------------------------------------------------------------------------------------
% Verbindungspunkte anlegen (jede Last im SINCAL-Netz entspricht einem Knoten, an dem
% eine Einheit angeschlossen werden kann a.k.a. Hausanschluss:
%------------------------------------------------------------------------------------
Grid.P_Q_Node.Points = Connection_Point.empty(numel(Grid.P_Q_Node.ids),0);
for i=1:numel(Grid.P_Q_Node.ids)
	Grid.P_Q_Node.Points(i) = Connection_Point(sin, Grid.P_Q_Node.ids(i));
end

% Sortieren der Namen:
[~, IX] = sort({Grid.P_Q_Node.Points.P_Q_Name});
Grid.P_Q_Node.Points = Grid.P_Q_Node.Points(IX);
Grid.P_Q_Node.ids = Grid.P_Q_Node.ids(IX);

% Daten in Tabelle einstellen:
data = {Grid.P_Q_Node.Points.P_Q_Name}';
data(:,2) = deal({false});
data(:,3) = deal(handles.System.housholds(1,1));
ColumnName = {'Names', 'Selection', 'Haush. Typ'};
ColumnFormat = {'char', 'logical', ...
	handles.System.housholds(:,1)'};
ColumnEditable = [false, true, true];
RowName = [];

% SINCAL-Objekt speichern:
handles.sin = sin;
% Netzobjekte speichern:
handles.Grid = Grid;

handles.Current_Settings.Table_Network.Data = data;
handles.Current_Settings.Table_Network.ColumnName = ColumnName;
handles.Current_Settings.Table_Network.ColumnEditable = ColumnEditable;
handles.Current_Settings.Table_Network.ColumnFormat = ColumnFormat;
handles.Current_Settings.Table_Network.RowName = RowName;

% Etwaige bereits geladene Daten und Simulationsergebnisse zurücksetzen:
if isfield(handles, 'Result')
    handles = rmfield(handles, 'Result');
end

% Versuch, die letzten Lastdaten dieses Netzes zu laden:
try
	% automatisch gespeicherte Last- und Einspeisedaten laden:
	grid = handles.Current_Settings.Grid;
	file = handles.Current_Settings.Auto_Load_Feed_Data;
	file.Path = [grid.Path,filesep,grid.Name,'_files'];
	% Laden von 'Load_Feed_Data', 'Data_Extract', 'Table_Network':
	load('-mat', [file.Path,filesep,file.Name,file.Exte]);
	
	handles.Result.Households = Load_Feed_Data;
	handles.Current_Settings.Data_Extract = Data_Extract;
	handles.Current_Settings.Table_Network = Table_Network;
	% Anzahl der jeweiligen Haushalte ermitteln:
	for i=1:size(handles.System.housholds,1)
		handles.Current_Settings.Households.(handles.System.housholds{i,1}).Number = ...
			sum(strcmp(handles.System.housholds{i,1},Table_Network.Data(:,3)));
	end
catch ME
	disp('Fehler beim Laden der Last- und Einspeisedaten:');
	disp(ME.message);
end
end

