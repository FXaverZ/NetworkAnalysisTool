function handles = network_calculation(handles)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Version:                 1.0
% Erstellt von:            Franz Zeilinger - 05.02.2013
% Letzte Änderung durch:   Franz Zeilinger - 27.02.2013

% Zugriff auf Datenobjekt:
d = handles.NAT_Data;

Table_Data = handles.Current_Settings.Table_Network.Data;
Current_Settings = handles.Current_Settings;
cg = handles.sin.Settings.Grid_name;

%------------------------------------------------------------------------------------
% Übernehmen der akutell geladen Daten:
%------------------------------------------------------------------------------------
if Current_Settings.Data_Extract.get_Max_Value
	d.Grid.(cg).Load.Data = d.Load_Infeed_Data.Households.Data_Max;
	d.Grid.(cg).Sola.Data = d.Load_Infeed_Data.Solar.Data_Max;
end
if Current_Settings.Data_Extract.get_Min_Value
	d.Grid.(cg).Load.Data = d.Load_Infeed_Data.Households.Data_Min;
	d.Grid.(cg).Sola.Data = d.Load_Infeed_Data.Solar.Data_Min;
end
if Current_Settings.Data_Extract.get_Sample_Value
	d.Grid.(cg).Load.Data = d.Load_Infeed_Data.Households.Data_Sample;
	d.Grid.(cg).Sola.Data = d.Load_Infeed_Data.Solar.Data_Sample;
end
if Current_Settings.Data_Extract.get_Mean_Value
	d.Grid.(cg).Load.Data = d.Load_Infeed_Data.Households.Data_Mean;
	d.Grid.(cg).Sola.Data = d.Load_Infeed_Data.Solar.Data_Mean;
end

% Die Daten an SINCAL anpassen (Leistungen in MW und pos. bei Verbrauch):
d.Grid.(cg).Load.Data = d.Grid.(cg).Load.Data/1e6;
d.Grid.(cg).Sola.Data = d.Grid.(cg).Sola.Data/-1e6; %Einspeiser negativ!
% Wieviele Zeitpunkte werden berechnet?
Current_Settings.Simulation.Timepoints = size(d.Grid.(cg).Load.Data,1);
handles.Current_Settings = Current_Settings;
% Leeres Netz-Array erstellen:
d.Result.(handles.sin.Settings.Grid_name) = [];
d.Simulation = [];
%------------------------------------------------------------------------------------
% Lasten ins Netz einfügen:
%------------------------------------------------------------------------------------
d.Grid.(cg).Load.Loads = Unit_Time_Dependent.empty(0,numel(d.Grid.(cg).P_Q_Node.ids));
hhs = Current_Settings.Data_Extract.Households;
for i=1:numel(d.Grid.(cg).P_Q_Node.ids)
	% Welcher Haushaltstyp soll angeschlossen werden?
	hh_typ = Table_Data{i,3};
	idx = find(strcmp(hh_typ,d.Load_Infeed_Data.Households.Content));
	idx = idx(hhs.(hh_typ).Number)-1;
	hhs.(hh_typ).Number = hhs.(hh_typ).Number - 1;
	% Last-Instanz erzeugen:
	obj = Unit_Time_Dependent(...
		d.Grid.(cg).P_Q_Node.Points(i),...                   % Anschlusspunkt-Objekt
		d.Grid.(cg).Load.Data(:,(idx*6)+1:(idx*6)+6));       % Lastgang des Last
% 	disp([Grid.P_Q_Node.Points(i).P_Q_Name,' --> ',hh_typ]);
	d.Grid.(cg).Load.Loads(i) = obj;
end

%------------------------------------------------------------------------------------
% Erzeuger einfügen
%------------------------------------------------------------------------------------
add_data = Current_Settings.Table_Network.Additional_Data;
num_unit = size(d.Grid.(cg).Sola.Data,2)/6;
d.Grid.(cg).Sola.Gen_Units = Unit_Time_Dependent.empty(0,num_unit);
plants = Current_Settings.Data_Extract.Solar.Plants;
gen_count = 1;
for i=1:numel(d.Grid.(cg).P_Q_Node.ids)
	gen_unit_name = add_data{i,1};
	if isempty(gen_unit_name)
		continue;
	end
	idx = find(strcmp(gen_unit_name,d.Load_Infeed_Data.Solar.Content));
	idx = idx(plants.(gen_unit_name).Number) - 1;
	plants.(gen_unit_name).Number = plants.(gen_unit_name).Number - 1;
	% Last-Instanz erzeugen:
	obj = Unit_Time_Dependent(...
		d.Grid.(cg).P_Q_Node.Points(i),...                   % Anschlusspunkt-Objekt
		d.Grid.(cg).Sola.Data(:,(idx*6)+1:(idx*6)+6));       % Lastgang des Last
	d.Grid.(cg).Sola.Gen_Units(gen_count) = obj;
	gen_count = gen_count + 1;
end

% ------------------------------------
% Zunächst Fall ohne Regelung rechnen:
% ------------------------------------

fprintf('\nStarte Netz-Simulation...\n');

% noch die aktuellen Einstellungen speichern:
d.Simulation.Grid_act = cg;

% DEBUG: Every time a calculation is performed, also the counter of dataset
% is raised:
if ~isfield(d.Simulation, 'Input_Data_act')
	d.Simulation.Input_Data_act = 1;
else
	d.Simulation.Input_Data_act = d.Simulation.Input_Data_act + 1;
end

% d.Result.Grid.Load.node_voltage = zeros(...
% 	size(d.Grid.P_Q_Node.Points,2),3,Current_Settings.Simulation.Timepoints);
% d.Result.Grid.Lines.currents = zeros(...
%     numel(d.Grid.Branches.Lines),4,Current_Settings.Simulation.Timepoints);
tic; %Zeitmessung start
for k=1:Current_Settings.Simulation.Timepoints
	
	% aktuellen Zeipunkt speichern:
	d.Simulation.Current_timepoint = k;
	% Last- und Einspeisedaten aktualisieren:
	d.Grid.(cg).Load.Loads.update_power(k);
	d.Grid.(cg).Sola.Gen_Units.update_power(k);
	
	% der Berechnung die neuen Leistungswerte übermitteln:
	d.Grid.(cg).P_Q_Node.Points.update_power;
	
	% Lastfluss rechnen:
	handles.sin.start_calculation;
	
	% here the analyzing function is called. Because the data is stored
	% within the NAT_Data-object, on which this function has access, no
	% return value is neccesary:
% 	analyzing_function_1 (handles);
% 	online_branch_violation_analysis(handles);
	online_voltage_analysis(handles);
	
	% alle Last-Knoten-Spannungen auslesen:
% 	d.Grid.(cg).P_Q_Node.Points.update_voltage_node_LF_USYM;
% 	d.Result.Grid.Load.node_voltage(:,:,k) = vertcat(d.Grid.(cg).P_Q_Node.Points.Voltage);
%   d.Grid.(cg).Branches.Lines.update_current_branch_LF_USYM;
%   d.Result.Grid.Lines.currents(:,:,k) = vertcat(d.Grid.(cg).Branches.Lines.Current);
	
	% Statusinfo zum Gesamtfortschritt an User:
	t = toc;
	progress = k/Current_Settings.Simulation.Timepoints;
	time_elapsed = t/progress - t;
	fprintf(['\t\t\tLastfluss Nr. ',num2str(k),' von ',...
		num2str(Current_Settings.Simulation.Timepoints),' abgeschlossen. Laufzeit: ',...
		sec2str(t),...
		'. Verbleibende Zeit: ',...
		sec2str(time_elapsed),'\n']);
end
t = toc;
fprintf('\t\t--> erledigt!\n');
fprintf(['\tBerechnungen beendet nach ',sec2str(t)]);

handles.Current_Settings = Current_Settings;

% handles = adopt_data_for_display(handles);

end

