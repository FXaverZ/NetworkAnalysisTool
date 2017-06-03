function handles = network_load (handles)
%LOAD_NETWORK    Summary of this function goes here
%    Detailed explanation goes here

% Version:                 1.3
% Erstellt von:            Franz Zeilinger - 04.02.2013
% Letzte �nderung durch:   Matej Rejc      - 24.04.2013

% Einstellungen und Systemvariablen auslesen:
settin = handles.Current_Settings;

% Zugriff auf Datenobjekt:
d = handles.NAT_Data;

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

% Name of the current grid:
cg = sin.Settings.Grid_name;

% Auslesen der aktuellen Tabelle mit den Elementdaten
sin.table_data_load('Element');
sin.table_data_load('Node');
sin.table_data_load('VoltageLevel');

% Element-IDs aller SINCAL-Lasten auslesen:
d.Grid.(cg).P_Q_Node.ids = cell2mat(sin.Tables.Element(...
	strncmp(sin.Tables.Element(:,strcmp(sin.Tables.Element(1,:),'Type')),'Load',4),...
	strcmp(sin.Tables.Element(1,:),'Element_ID')...
	));
% Element-IDs aller Knoten auslesen:
d.Grid.(cg).All_Node.ids = cell2mat(sin.Tables.Node(2:end,...
	strcmp(sin.Tables.Node(1,:),'Node_ID')...
	));
% Element-IDs aller Leitungen auslesen:
d.Grid.(cg).Branches.line_ids = cell2mat(sin.Tables.Element(...
	strncmp(sin.Tables.Element(:,strcmp(sin.Tables.Element(1,:),'Type')),'Line',4),...
	strcmp(sin.Tables.Element(1,:),'Element_ID')...
	));
% Element-IDs aller Transformatoren auslesen:
d.Grid.(cg).Branches.tran_ids = cell2mat(sin.Tables.Element(...
	strncmp(sin.Tables.Element(:,strcmp(sin.Tables.Element(1,:),'Type')),'TwoWindingTrans',15),...
	strcmp(sin.Tables.Element(1,:),'Element_ID')...
	));

%------------------------------------------------------------------------------------
% Verbindungspunkte anlegen (jede Last im SINCAL-Netz entspricht einem Knoten, an dem
% eine Einheit angeschlossen werden kann a.k.a. Hausanschluss):
d.Grid.(cg).P_Q_Node.Points = Connection_Point.empty(numel(d.Grid.(cg).P_Q_Node.ids),0);
for i=1:numel(d.Grid.(cg).P_Q_Node.ids)
	d.Grid.(cg).P_Q_Node.Points(i) = Connection_Point(sin, d.Grid.(cg).P_Q_Node.ids(i));
end
% Allgemeine Knoten-Objekte erstellen: 
d.Grid.(cg).All_Node.Points = Connection_All_Point.empty(numel(d.Grid.(cg).All_Node.ids),0);
for i=1:numel(d.Grid.(cg).All_Node.ids)
    d.Grid.(cg).All_Node.Points(i) = Connection_All_Point(sin, d.Grid.(cg).All_Node.ids(i));
end
% Define Node-Voltage limits:
d.Grid.(cg).All_Node.Points.define_voltage_limits;

% Zugriffobjekte f�r alle Leitungen erstellen:
d.Grid.(cg).Branches.Lines = Branch.empty(numel(d.Grid.(cg).Branches.line_ids),0);
for i=1:numel(d.Grid.(cg).Branches.line_ids)
    d.Grid.(cg).Branches.Lines(i) = Branch(sin, d.Grid.(cg).Branches.line_ids(i));
end
% Define branch-line limits
d.Grid.(cg).Branches.Lines.define_branch_limits;

% Create object for access of transformer objects:
d.Grid.(cg).Branches.Transf = Branch.empty(numel(d.Grid.(cg).Branches.tran_ids),0);
for i=1:numel(d.Grid.(cg).Branches.tran_ids)
    d.Grid.(cg).Branches.Transf(i) = Branch(sin, d.Grid.(cg).Branches.tran_ids(i));
end
% Define branch-transf limits
d.Grid.(cg).Branches.Transf.define_branch_limits;

% Sortieren der Namen:
[~, IX] = sort({d.Grid.(cg).P_Q_Node.Points.P_Q_Name});
d.Grid.(cg).P_Q_Node.Points = d.Grid.(cg).P_Q_Node.Points(IX);
d.Grid.(cg).P_Q_Node.ids = d.Grid.(cg).P_Q_Node.ids(IX);

[~, IX] = sort({d.Grid.(cg).Branches.Lines.Branch_Name});
d.Grid.(cg).Branches.Lines = d.Grid.(cg).Branches.Lines(IX);
d.Grid.(cg).Branches.line_ids = d.Grid.(cg).Branches.line_ids(IX);

[~, IX] = sort({d.Grid.(cg).Branches.Transf.Branch_Name});
d.Grid.(cg).Branches.Transf = d.Grid.(cg).Branches.Transf(IX);
d.Grid.(cg).Branches.tran_ids = d.Grid.(cg).Branches.tran_ids(IX);

% Merge Lines and transformers into one group!
d.Grid.(cg).Branches.group_ids = [d.Grid.(cg).Branches.line_ids;
	d.Grid.(cg).Branches.tran_ids];
d.Grid.(cg).Branches.Grouped = [d.Grid.(cg).Branches.Lines,...
	d.Grid.(cg).Branches.Transf];

% SINCAL-Objekt speichern:
handles.sin = sin;
end

