function handles = network_load (handles)
%LOAD_NETWORK    Summary of this function goes here
%    Detailed explanation goes here

% Version:                 1.0
% Erstellt von:            Franz Zeilinger - 04.02.2013
% Letzte Änderung durch:   Franz Zeilinger - 

% Einstellungen und Systemvariablen:
settin = handles.Current_Settings;
system = handles.System;
data_o = handles.NAT_Data;

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
%-- changelog v1.1 (start) // 2013041
sin.table_data_load('Node'); 
sin.table_data_load('VoltageLevel'); 
%-- changelog v1.1 (end) // 2013041

% Element-IDs aller SINCAL-Lasten auslesen:
data_o.Grid.P_Q_Node.ids = cell2mat(sin.Tables.Element(...
	strncmp(sin.Tables.Element(:,strcmp(sin.Tables.Element(1,:),'Type')),'Load',4),...
	strcmp(sin.Tables.Element(1,:),'Element_ID')...
	));
% -- changelog v1.1b ##### (start) // 20130415
data_o.Grid.Branches.line_ids = cell2mat(sin.Tables.Element(...
	strncmp(sin.Tables.Element(:,strcmp(sin.Tables.Element(1,:),'Type')),'Line',4),...
	strcmp(sin.Tables.Element(1,:),'Element_ID')...
	));

data_o.Grid.Branches.tran_ids = cell2mat(sin.Tables.Element(...
	strncmp(sin.Tables.Element(:,strcmp(sin.Tables.Element(1,:),'Type')),'TwoWindingTrans',15),...
	strcmp(sin.Tables.Element(1,:),'Element_ID')...
	));
% -- changelog v1.1b ##### (end) // 20130415


% -- changelog v1.1b ##### (start) // 20130411
data_o.Grid.All_Node.ids = cell2mat(sin.Tables.Node(2:end,...
	strcmp(sin.Tables.Node(1,:),'Node_ID')...
	)); 
% -- changelog v1.1b ##### (end) // 20130411

%------------------------------------------------------------------------------------
% Verbindungspunkte anlegen (jede Last im SINCAL-Netz entspricht einem Knoten, an dem
% eine Einheit angeschlossen werden kann a.k.a. Hausanschluss:
%------------------------------------------------------------------------------------
data_o.Grid.P_Q_Node.Points = Connection_Point.empty(numel(data_o.Grid.P_Q_Node.ids),0);
for i=1:numel(data_o.Grid.P_Q_Node.ids)
	data_o.Grid.P_Q_Node.Points(i) = Connection_Point(sin, data_o.Grid.P_Q_Node.ids(i));
end

% -- changelog v1.1b ##### (start) // 20130411
data_o.Grid.All_Node.Points = Connection_All_Point.empty(numel(data_o.Grid.All_Node.ids),0);
for i=1:numel(data_o.Grid.All_Node.ids)
    data_o.Grid.All_Node.Points(i) = Connection_All_Point(sin, data_o.Grid.All_Node.ids(i));
end
data_o.Grid.All_Node.Points.define_voltage_limits;
% -- changelog v1.1b ##### (end) // 20130411

% -- changelog v1.1b ##### (start) // 20130415
% Define lines!
data_o.Grid.Branches.Lines = Branch.empty(numel(data_o.Grid.Branches.line_ids),0);
for i=1:numel(data_o.Grid.Branches.line_ids)
    data_o.Grid.Branches.Lines(i) = Branch(sin, data_o.Grid.Branches.line_ids(i));
end
% Define branch-line limits
data_o.Grid.Branches.Lines.define_branch_limits;

% Define transformers
data_o.Grid.Branches.Transf = Branch.empty(numel(data_o.Grid.Branches.tran_ids),0);
for i=1:numel(data_o.Grid.Branches.tran_ids)
    data_o.Grid.Branches.Transf(i) = Branch(sin, data_o.Grid.Branches.tran_ids(i));
end
% Define  branch-transf limits
data_o.Grid.Branches.Transf.define_branch_limits;
% -- changelog v1.1b ##### (end) // 20130415

% Sortieren der Namen:
[~, IX] = sort({data_o.Grid.P_Q_Node.Points.P_Q_Name});
data_o.Grid.P_Q_Node.Points = data_o.Grid.P_Q_Node.Points(IX);
data_o.Grid.P_Q_Node.ids = data_o.Grid.P_Q_Node.ids(IX);

% -- changelog v1.1b ##### (start) // 20130415
[~, IX] = sort({data_o.Grid.Branches.Lines.Branch_Name});
data_o.Grid.Branches.Lines = data_o.Grid.Branches.Lines(IX);
data_o.Grid.Branches.line_ids = data_o.Grid.Branches.line_ids(IX);

[~, IX] = sort({data_o.Grid.Branches.Transf.Branch_Name});
data_o.Grid.Branches.Transf = data_o.Grid.Branches.Transf(IX);
data_o.Grid.Branches.tran_ids = data_o.Grid.Branches.tran_ids(IX);
% -- changelog v1.1b ##### (end) // 20130415

% SINCAL-Objekt speichern:
handles.sin = sin;

% Tabelle mit Default-Werten befüllen:
[settin.Table_Network, settin.Data_Extract] = network_table_reset(handles);

% Etwaige bereits geladene Daten und Simulationsergebnisse zurücksetzen:
handles.NAT_Data.Result = [];

% Versuch, die letzten Lastdaten dieses Netzes zu laden:
try
	% automatisch gespeicherte Last- und Einspeisedaten laden:
	file = settin.Files.Auto_Load_Feed_Data;
	file.Path = [settin.Files.Grid.Path,filesep,settin.Files.Grid.Name,'_files'];
	% Laden von 'Load_Feed_Data', 'Data_Extract', 'Table_Network':
	load('-mat', [file.Path,filesep,file.Name,file.Exte]);
	
	handles.NAT_Data.Result.Households = Load_Feed_Data;
	handles.NAT_Data.Result.Solar = Gene_Sola_Data;
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

