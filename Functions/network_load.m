function handles = network_load (handles)
%LOAD_NETWORK    Summary of this function goes here
%    Detailed explanation goes here

% Version:                 1.0
% Erstellt von:            Franz Zeilinger - 04.02.2013
% Letzte Änderung durch:   Franz Zeilinger - 

% Einstellungen und Systemvariablen:
settin = handles.Current_Settings;
system = handles.System;

if ~isfield(handles, 'sin')
	% Erzeugen der SINCAL-Instanz:
	sin = SINCAL(settin.Simulation.Parameters{:},...
		'Grid_name', settin.Files.Grid.Name,...
		'Grid_path', settin.Files.Grid.Path);
	sin.open_database;
else
	sin = handles.sin;
	sin.update_settings(settin.Simulation.Parameters{:},...
		'Grid_name', settin.Files.Grid.Name,...
		'Grid_path', settin.Files.Grid.Path);
end

% Auslesen der aktuellen Tabelle mit den Elementdaten
sin.table_data_load('Element');

% Element-IDs aller SINCAL-Lasten auslesen:
Grid.P_Q_Node.ids = cell2mat(sin.Tables.Element(...
	strncmp(sin.Tables.Element(:,strcmp(sin.Tables.Element(1,:),'Type')),'Load',4),...
	strcmp(sin.Tables.Element(1,:),'Element_ID')...
	));
Grid.Branches.ids = cell2mat(sin.Tables.Element(...
	strncmp(sin.Tables.Element(:,strcmp(sin.Tables.Element(1,:),'Type')),'Line',4),...
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

Grid.Branches.Lines = Branch.empty(numel(Grid.Branches.ids),0);
for i=1:numel(Grid.Branches.ids)
    Grid.Branches.Lines(i) = Branch(sin, Grid.Branches.ids(i));
end

% Sortieren der Namen:
[~, IX] = sort({Grid.P_Q_Node.Points.P_Q_Name});
Grid.P_Q_Node.Points = Grid.P_Q_Node.Points(IX);
Grid.P_Q_Node.ids = Grid.P_Q_Node.ids(IX);

[~, IX] = sort({Grid.Branches.Lines.Branch_Name});
Grid.Branches.Lines = Grid.Branches.Lines(IX);
Grid.Branches.ids = Grid.Branches.ids(IX);

% SINCAL-Objekt speichern:
handles.sin = sin;
% Netzobjekte speichern:
handles.Grid = Grid;

% Tabelle mit Default-Werten befüllen:
[settin.Table_Network, settin.Data_Extract] = network_table_reset(handles);

% Etwaige bereits geladene Daten und Simulationsergebnisse zurücksetzen:
if isfield(handles, 'Result')
    handles = rmfield(handles, 'Result');
end

% Versuch, die letzten Lastdaten dieses Netzes zu laden:
try
	% automatisch gespeicherte Last- und Einspeisedaten laden:
	file = settin.Files.Auto_Load_Feed_Data;
	file.Path = [settin.Files.Grid.Path,filesep,settin.Files.Grid.Name,'_files'];
	% Laden von 'Load_Feed_Data', 'Data_Extract', 'Table_Network':
	load('-mat', [file.Path,filesep,file.Name,file.Exte]);
	
	handles.Result.Households = Load_Feed_Data;
	handles.Result.Solar = Gene_Sola_Data;
	settin.Data_Extract = Data_Extract;
	settin.Table_Network = Table_Network;
	% Anzahl der jeweiligen Haushalte ermitteln:
	for i=1:size(system.housholds,1)
		settin.Data_Extract.Households.(system.housholds{i,1}).Number = ...
			sum(strcmp(system.housholds{i,1},Table_Network.Data(:,3)));
	end
catch ME
	disp('Fehler beim Laden der Last- und Einspeisedaten:');
	disp(ME.message);
end

handles.Current_Settings = settin;
end

